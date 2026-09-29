# Dendritic nix flake

Uses flake-parts to make every file under `modules/` a flake module.

## Services

Registry: `modules/homelab/hlServices.nix` — a host of `-` means the service
module exists but is not enabled on any machine. 

<!-- services-table:start -->
|     Service      |  Machine  |    Port    |  Subdomain  |  Private  |
| :--------------: | :-------: | :--------: | :---------: | :-------: |
|       anki       |   27701   |  "oracle"  |      -      |     n     |
|      atticd      |   27702   |  "oracle"  |      -      |     n     |
|      atuin       |   8888    |  "oracle"  |      -      |     n     |
|  audiobookshelf  |   8000    |     ""     |      -      |     n     |
|      bazarr      |   6767    |   "u410"   |      -      |     n     |
|      caddy       |     0     |  "oracle"  |      -      |     n     |
|     calibre      |   8083    |  "oracle"  |      -      |     n     |
|    copyparty     |   3210    |   "u410"   |      -      |     n     |
|     forgejo      |   3000    |  "oracle"  |      -      |     n     |
|  home-assistant  |   8123    |   "u410"   |      -      |     n     |
|      immich      |   2283    |   "u410"   |      -      |     n     |
|     jellyfin     |   8096    |   "u410"   |      -      |     n     |
|      lidarr      |   8686    |   "u410"   |      -      |     n     |
|    linkwarden    |   9183    |   "u410"   |      -      |     n     |
|      mealie      |   9876    |  "oracle"  |      -      |     n     |
|    navidrome     |   4533    |   "u410"   |      -      |     n     |
|    nextcloud     |     0     |     ""     |      -      |     n     |
|       ntfy       |   4198    |  "oracle"  |      -      |     n     |
|     prowlarr     |   9696    |     ""     |      -      |     n     |
|   qbittorrent    |   7877    |     ""     |      -      |     n     |
|      radarr      |   7878    |   "u410"   |      -      |     n     |
|      seerr       |   5055    |     ""     |      -      |     n     |
|       site       |     0     |  "oracle"  |      -      |     n     |
|      slskd       |   5030    |   "u410"   |      -      |     n     |
|      sonarr      |   8989    |   "u410"   |      -      |     n     |
|   sports-ntfy    |     0     |  "oracle"  |      -      |     n     |
|        t3        |   3773    |  "oracle"  |      -      |     n     |
|   vaultwarden    |   8222    |  "oracle"  |      -      |     n     |
<!-- services-table:end -->

The services table above is auto-generated from `modules/homelab/hlServices.nix` 
by `scripts/update-services-readme.sh`
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

Cache entries are configured with a `3 days` retention period by the workflow.

## Remote builders

`modules/nix.nix` configures remote build machines, filtered per host so a
machine never builds on itself:
`oracle:2222` (`aarch64-linux`), `u410:2222` (`x86_64-linux`),
`mba:22` (`aarch64-darwin`). Each entry pins the SSH host key
(`publicHostKey`) and uses a sops-managed key (`sops.secrets."ssh/<host>"`)
as `sam` over `ssh-ng`, so builds are non-interactive and MITM-resistant.
