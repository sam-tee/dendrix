# Dendritic nix flake

Uses flake-parts to make every file under `modules/` a flake module.

## Services

Registry: `modules/vars/homelab.nix` — a host of `-` means the service
module exists but is not enabled on any machine. 

<!-- services-table:start -->
|     Service      |  Machine  |  Port   |  Subdomain  |
| :--------------: | :-------: | :-----: | :---------: |
|       anki       |  oracle   |  27701  |    anki     |
|      atticd      |  oracle   |  27702  |    cache    |
|      atuin       |  oracle   |  8888   |    atuin    |
|  audiobookshelf  |     -     |  8000   |    audio    |
|      bazarr      |   u410    |  6767   |   bazarr    |
|      caddy       |  oracle   |    -    |      -      |
|     calibre      |  oracle   |  8083   |    books    |
|    copyparty     |   u410    |  3210   |    files    |
|     forgejo      |  oracle   |  3000   |     git     |
|  home-assistant  |   u410    |  8123   |     ha      |
|      immich      |   u410    |  2283   |   photos    |
|     jellyfin     |   u410    |  8096   |    media    |
|      lidarr      |   u410    |  8686   |   lidarr    |
|    linkwarden    |   u410    |  9183   |    link     |
|      mealie      |  oracle   |  9876   |   cooking   |
|    navidrome     |   u410    |  4533   |    music    |
|    nextcloud     |     -     |    -    |      -      |
|       ntfy       |  oracle   |  4198   |    ntfy     |
|     prowlarr     |     -     |  9696   |  prowlarr   |
|   qbittorrent    |     -     |  7877   |   torrent   |
|      radarr      |   u410    |  7878   |   radarr    |
|      seerr       |     -     |  5055   |    seerr    |
|       site       |  oracle   |    -    |      -      |
|      slskd       |   u410    |  5030   |    slskd    |
|      sonarr      |   u410    |  8989   |   sonarr    |
|   sports-ntfy    |  oracle   |    -    |      -      |
|        t3        |  oracle   |  3773   |     t3      |
|   vaultwarden    |  oracle   |  8222   |    vault    |
<!-- services-table:end -->

The services table above is auto-generated from `modules/vars/homelab.nix` 
by `scripts/update-services-readme.sh`
(run by `.forgejo/workflows/cache.yml` on every push).

## Hosts

| Host | System | Type | Role |
| ---- | ------ | ---- | ---- |
| `a3` | `x86_64-linux` | NixOS desktop | Hyprland, autologin, Steam, Sunshine, VMs |
| `s340` | `x86_64-linux` | NixOS desktop | Niri |
| `hp` | `x86_64-linux` | NixOS server | Spare server |
| `u410` | `x86_64-linux` | NixOS server | Data-heavy/media services, `x86_64-linux` builder, `dataDir=/mnt/data` |
| `oracle` | `aarch64-linux` | NixOS cloud server | Caddy reverse proxy, public services, Forgejo, Attic cache, `aarch64-linux` builder |
| `mba` | `aarch64-darwin` | nix-darwin | macOS desktop (paneru) |
| `duet` | `lenovo-krane` | mobile-nixos | Chromebook (GNOME) |
| `duet3` | `lenovo-wormdingler` | mobile-nixos | Chromebook (Hyprland) |

`u410` hosts data-heavy services; `oracle` handles Caddy and selected
services. Each machine is reachable over SSH as its hostname (see `AGENTS.md`).

## Layout

- `modules/hosts/`: host definitions (`flake.hosts` metadata) and per-host
  hardware/config, via `self.lib.mkNixos` / `mkDarwin` / `mkMobile`
  (plus `git`/`git-sign` key-only entries in `other.nix`).
- `modules/homelab/`: homelab service modules (`flake.modules.nixos.<name>`),
  auto-imported for the matching host by the `default` module in `mkServer.nix`;
  `server` is the shared headless-server bundle (passwordless wheel sudo).
- `modules/vars/`: flake-wide registries — `homelab.nix` (`flake.services`
  placements via `mkService`, plus `domain`/`tailnet`) and `cosmetic.nix`
  (theme, fonts, cursor).
- `modules/lib/`: helpers (`mkNixos`, `mkDarwin`, `mkMobile`, `mkService`,
  `mkRemoteBuilder`, `mkTsIp`).
- `modules/system/`: shared system modules (ssh, sops, user, networking,
  tailscale, syncthing, boot, fail2ban, battery, disko, fonts, vms, ...).
- `modules/cli/`, `modules/gui/`, `modules/de/`, `modules/ai/`: CLI tools,
  GUI apps, desktop environments, and AI tooling (ollama, t3code).
- `modules/nixvim/`: Neovim (nixvim) configuration.
- `modules/nix.nix`, `modules/hjem.nix`, `modules/flake-parts.nix`,
  `modules/options/`, `modules/packages/`: nix settings (substituters,
  remote builders) and cache config, hjem, flake plumbing, shared option
  definitions, and extra packages (per-system configs, `pyScripts`
  passthrough, `t3code` slim builds).
- `nix-secrets/`: sops-encrypted secrets (see below).

## Secrets

Secrets live in `nix-secrets/secrets.yaml`, sops-encrypted with per-machine
age keys (see `nix-secrets/.sops.yaml`). The default sops file is wired up in
`modules/system/sops.nix`.

## Binary cache

`oracle` runs Attic at `https://cache.samtee.party/`.
Forgejo Actions updates `flake.lock` on schedule/dispatch, builds all packages for
`x86_64-linux` + `aarch64-linux` with `nix-fast-build --skip-cached
--attic-cache dendrix`, syncs this README's services table, commits
`flake.lock`, and sends a ntfy notification. Pushes
also rebuild and upload the current outputs. All clients use
`https://cache.samtee.party/dendrix` as substituter (see `modules/nix.nix`).

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
attic login --set-default dendrix https://cache.samtee.party "$TOKEN"
attic use dendrix
```

Then switch as usual:

```sh
sudo nixos-rebuild switch --flake ~/dendrix#u410
```

Cache entries are garbage-collected after `3 days` by the server
(`garbage-collection.default-retention-period` in `modules/homelab/atticd.nix`).

## Remote builders

`modules/nix.nix` configures remote build machines (via `mkRemoteBuilder`),
filtered per host so a machine never builds on itself: `oracle`
(`aarch64-linux`), `u410` (`x86_64-linux`, 2 jobs), `a3` (`x86_64-linux`,
8 jobs, 2x speed factor), all on port `2222`. Each entry pins the SSH host
key (`publicHostKey`) and authenticates over `ssh-ng` as the host's user
with a sops-managed key (`sops.secrets."ssh/<host>"`), so builds are
non-interactive and MITM-resistant.
