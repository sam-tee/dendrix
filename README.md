# Dendritic nix flake

Uses flake-parts to make every file under `modules/` a flake module.

## Services

See [services.md](docs/services.md) for the full list of services and the
ports, hosts and subdomains they run on. This file is programmatically
updated from `modules/vars/homelab.nix`.

## Hosts

See [hosts.md](docs/hosts.md) for the full table generated from
`modules/hosts/*.nix`. Hardware modules are auto-imported for
desktop and server configs.

## Layout

- `modules/hosts/`: host definitions (`flake.hosts` metadata: `hostType`,
  `modules` list, ...) auto-wired into configurations by `mkConfig`, plus
  per-host hardware/config
  (plus `git`/`git-sign` key-only entries in `other.nix`).
- `modules/homelab/`: homelab service modules (`flake.modules.nixos.<name>`),
  auto-imported for the matching host by the `default` module in `mapServerModules.nix`;
  `server` is the shared headless-server bundle (passwordless wheel sudo).
- `modules/vars/`: flake-wide registries — `homelab.nix` (`flake.services`
  placements via `mkService`, plus `domain`/`tailnet`) and `cosmetic.nix`
  (theme, fonts, cursor).
- `modules/lib/`: helpers (`mkNixos`, `mkServer`, `mkDarwin`, `mkMobile`,
  `mkConfig`, `mkService`,
  `mkRemoteBuilder`, `mkTsIp`).
- `docs/`: generated services/hosts tables (do not edit;
  see `scripts/update-*-docs.sh`), linked from the sections above.
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

See [atticd.md](docs/atticd.md) for details on setting up the cache server
and using it from a machine before switching that machine to this config.

## Remote builders

`modules/nix.nix` configures remote build machines (via `mkRemoteBuilder`),
filtered per host so a machine never builds on itself: `oracle`
(`aarch64-linux`), `u410` (`x86_64-linux`, 2 jobs), `a3` (`x86_64-linux`,
8 jobs, 2x speed factor), all on port `2222`. Each entry pins the SSH host
key (`publicHostKey`) and authenticates over `ssh-ng` as the host's user
with a sops-managed key (`sops.secrets."ssh/<host>"`), so builds are
non-interactive and MITM-resistant.
