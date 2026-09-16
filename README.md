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
|     grimmory     |     -     |  6060   |  grimmory   |     n     |
|  home-assistant  |   u410    |  8123   |     ha      |     y     |
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
|   sports-ntfy    |  oracle   |    -    |      -      |     n     |
|     stirling     |     -     |  8998   |     pdf     |     y     |
|     terraria     |     -     |  4197   |  terraria   |     n     |
|   vaultwarden    |  oracle   |  8222   |    vault    |     n     |
<!-- services-table:end -->

Public `*.akhlus.uk` hosts and private `*.ts.akhlus.uk` hosts are reverse
proxied by Caddy on `oracle` over the tailnet. The services table above is auto-generated
from `modules/homelab/hlServices.nix` by `scripts/update-services-readme.sh`
(run by `.forgejo/workflows/cache.yml` on every push).

## Hosts

| Host | System | Type | Role |
| ---- | ------ | ---- | ---- |
| `a3` | `x86_64-linux` | NixOS desktop | Hyprland, autologin, Steam, VMs |
| `s340` | `x86_64-linux` | NixOS desktop | Niri |
| `hp` | `x86_64-linux` | NixOS server | Spare server |
| `u410` | `x86_64-linux` | NixOS server | Data-heavy/media services, `x86_64-linux` builder, `dataDir=/mnt/data` |
| `oracle` | `aarch64-linux` | NixOS cloud server | Caddy reverse proxy, public services, Forgejo, Attic cache, `aarch64-linux` builder |
| `mba` | `aarch64-darwin` | nix-darwin | macOS desktop (paneru) |
| `duet` | `lenovo-krane` | mobile-nixos | Chromebook (GNOME) |
| `duet3` | `lenovo-wormdingler` | mobile-nixos | Chromebook (Hyprland) |
| `corsola` | `asus-tentacruel` | mobile-nixos | Hyprland + GUI |

`u410` hosts data-heavy services; `oracle` handles Caddy and selected
services. Each machine is reachable over SSH as its hostname (see `AGENTS.md`).

## Layout

- `modules/hosts/`: host definitions (`flake.hosts` metadata) and per-host
  hardware/config, via `self.lib.mkNixos` / `mkDarwin` / `mkMobile`
  (plus `git`/`git-sign` key-only entries in `other.nix`).
- `modules/homelab/`: homelab service modules, the `hlServices.nix` service
  registry, and the `server` bundle that auto-imports services by their
  registered host.
- `modules/system/`: shared system modules (ssh, sops, users, networking,
  tailscale, syncthing, boot, fail2ban, battery, disko, fonts, vms).
- `modules/cli/`, `modules/gui/`, `modules/de/`: CLI tools, GUI apps, and
  desktop environments.
- `modules/nixvim/`: Neovim (nixvim) configuration.
- `modules/nix.nix`, `modules/hjem.nix`, `modules/flake-parts.nix`,
  `modules/options/`, `modules/types/`, `modules/packages/`: nix settings
  and cache config, hjem, flake plumbing, option/type definitions, and
  extra packages (`pyScripts`).
- `nix-secrets/`: sops-encrypted secrets (see below).

## Secrets

Secrets live in `nix-secrets/secrets.yaml`, sops-encrypted with per-machine
age keys (see `nix-secrets/.sops.yaml`). The default sops file is wired up in
`modules/system/sops.nix`.

## Binary cache

`oracle` runs Attic at `https://cache.akhlus.uk/`.
Forgejo Actions updates `flake.lock` on schedule/dispatch, builds all packages for
`x86_64-linux` + `aarch64-linux` with `nix-fast-build --skip-cached
--attic-cache dendrix`, syncs this README's services table, commits
`flake.lock`, and sends a ntfy notification. Pushes
also rebuild and upload the current outputs. All clients use
`https://cache.akhlus.uk/dendrix` as substituter (see `modules/nix.nix`).

The server needs a SOPS secret named `atticd-env` containing:

```sh
ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64=<openssl genrsa -traditional 4096 | base64 -w0>
```

After deploying, create a Forgejo cache token and store it as the repository
secret `ATTIC_TOKEN`:

```sh
sudo atticd-atticadm make-token --sub forgejo-cache --validity 1y --pull dendrix --push dendrix --create-cache dendrix --configure-cache dendrix --configure-cache-retention dendrix
```

Forgejo runs on `oracle`, so builds happen on the Forgejo runner there.

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

`modules/nix.nix` configures remote build machines, filtered per host so a
machine never builds on itself:
`oracle:2222` (`aarch64-linux`), `u410:2222` (`x86_64-linux`),
`mba:22` (`aarch64-darwin`). Each entry pins the SSH host key
(`publicHostKey`) and uses a sops-managed key (`sops.secrets."ssh/<host>"`)
as `sam` over `ssh-ng`, so builds are non-interactive and MITM-resistant.
