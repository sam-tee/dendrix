# Dendritic nix flake

Uses flake-parts to make every file under `modules/` a flake module.

## Services

Registry: `modules/homelab/hlServices.nix` — a host of `-` means the service
module exists but is not enabled on any machine. `private` services are only
reachable on the tailnet (`<sub>.ts.akhlus.uk`).

<!-- services-table:start -->
|     Service      |  Machine  |  Port   |  Subdomain  |  Private  |
| :--------------: | :-------: | :-----: | :---------: | :-------: |
|       anki       |     -     |  27701  |    anki     |     n     |
|      atticd      |  oracle   |  27702  |    cache    |     n     |
|      atuin       |  oracle   |  8888   |    atuin    |     n     |
|  audiobookshelf  |  oracle   |  8000   |    audio    |     y     |
|      bazarr      |   u410    |  6767   |   bazarr    |     y     |
|      caddy       |  oracle   |    -    |      -      |     y     |
|     calibre      |  oracle   |  8083   |    books    |     n     |
|     cockpit      |     -     |  9090   |    dash     |     y     |
|   code-server    |     -     |  4444   |    code     |     y     |
|    copyparty     |   u410    |  3210   |    files    |     y     |
|     forgejo      |  oracle   |  3000   |     git     |     n     |
|      immich      |   u410    |  2283   |   photos    |     n     |
|     jellyfin     |   u410    |  8096   |    media    |     n     |
|      lidarr      |   u410    |  8686   |   lidarr    |     y     |
|    linkwarden    |   u410    |  9183   |    link     |     n     |
|      mealie      |  oracle   |  9876   |   cooking   |     n     |
|    navidrome     |   u410    |  4533   |    music    |     n     |
|    nextcloud     |     -     |    -    |      -      |     y     |
|       ntfy       |  oracle   |  4198   |    ntfy     |     n     |
|     prowlarr     |   u410    |  9696   |  prowlarr   |     y     |
|   qbittorrent    |   u410    |  7877   |   torrent   |     y     |
|      radarr      |   u410    |  7878   |   radarr    |     y     |
|      seerr       |   u410    |  5055   |    seerr    |     y     |
|      slskd       |   u410    |  5030   |    slskd    |     y     |
|      sonarr      |   u410    |  8989   |   sonarr    |     y     |
|       site       |  oracle   |  8090   |    site     |     y     |
|     stirling     |     -     |  8998   |     pdf     |     y     |
|     terraria     |     -     |  4197   |  terraria   |     n     |
|   vaultwarden    |  oracle   |  8222   |    vault    |     n     |
<!-- services-table:end -->

Public `*.akhlus.uk` hosts and private `*.ts.akhlus.uk` hosts are reverse
proxied by Caddy on `oracle` over the tailnet. Modules that bundle other
modules are prefixed with `_`.

## Layout

- `modules/hosts/`: host definitions (`self.hosts` metadata) and per-host
  hardware/config, plus `self.lib.mkNixos` / `mkDarwin` / `mkMobile`.
- `modules/homelab/`: homelab service modules and the `server` bundle that
  auto-imports services by their registered host.
- `modules/system/`: shared system modules (ssh, sops, users, networking,
  tailscale, syncthing, boot, fail2ban).
- `modules/cli/`, `modules/gui/`, `modules/de/`: CLI tools, GUI apps and
  desktop environments (incl. macOS).
- `modules/nixvim/`: Neovim (nixvim) configuration.
- `modules/flake-parts/`, `modules/types/`, `modules/options/`: flake
  plumbing and option definitions.
- `nix-secrets/`: sops-encrypted secrets (see below).

## Secrets

Secrets live in `nix-secrets/secrets.yaml`, sops-encrypted with per-machine
age keys (see `nix-secrets/.sops.yaml`). The default sops file is wired up in
`modules/system/sops.nix`.

## Binary cache

`u410` runs Attic at `https://cache.akhlus.uk/`. Forgejo Actions updates
`flake.lock` daily, builds every `nixosConfiguration` plus Linux packages
exposed by the flake, and pushes the closures to the public `dendrix` cache.
Pushes to the repository also rebuild and upload the current outputs.

The server needs a SOPS secret named `atticd-env` containing:

```sh
ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64=<openssl genrsa -traditional 4096 | base64 -w0>
```

After deploying, create a Forgejo cache token and store it as the repository
secret `ATTIC_TOKEN`:

```sh
sudo atticd-atticadm make-token --sub forgejo-cache --validity 1y --pull dendrix --push dendrix --create-cache dendrix --configure-cache dendrix --configure-cache-retention dendrix
```

Forgejo runs on `u410`, so `x86_64-linux` outputs build locally in the runner
and `aarch64-linux` outputs use `u410`'s daemon-level Oracle builder
configuration. The Nix daemon on `u410` must be able to SSH to Oracle
non-interactively as `sam@oracle`, and the `sam` user on Oracle must be
allowed to use Nix remotely.

To use the cache before switching a machine, create a pull token and configure
the local Nix client once:

```sh
sudo atticd-atticadm make-token --sub sam --validity 1y --pull dendrix
attic login --set-default dendrix https://cache.akhlus.uk "$TOKEN"
attic use dendrix
```

Then switch as usual:

```sh
sudo nixos-rebuild switch --flake ~/dendrix#u410
```

Cache entries are configured with a `3 days` retention period by the workflow.

## Remote builders

`modules/nix.nix` configures remote build machines (`oracle`, `u410`, `mba`).
Each entry pins the SSH host key (`publicHostKey`) so builds are
non-interactive and MITM-resistant.
