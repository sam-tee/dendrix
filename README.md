# Dendritic nix flake

Uses flake-parts with an in-tree `import-tree` (`lib/importTree.nix`): every
`.nix` file under `hosts/`, `modules/`, `options/` and `vars/` is a flake
module, and every file under `lib/` adds helpers to `lib` (see Layout).
Files or directories starting with `_` are skipped.

## Services

See [services.md](docs/services.md) for the full list of services and the
ports, hosts and subdomains they run on. 

## Hosts

See [hosts.md](docs/hosts.md) for the full table generated from
`hosts/*.nix`. Hardware modules are auto-imported (and required)
for desktop and server configs; `<hostname>Disko` modules are auto-imported
when defined.

## Layout

- `hosts/`: host definitions (`flake.hosts` metadata: `hostType`,
  `modules` list, ...) auto-wired into configurations by
  `modules/configurations.nix`, plus per-host hardware/config
  (plus `git`/`git-sign` key-only entries in `other.nix`).
- `lib/`: plain helper files (not flake modules), each a function of
  `{lib, inputs, self}` returning an attrset that is merged over nixpkgs'
  `lib`. Flake, NixOS and darwin modules call them as `lib.<name>`
  (`mkNixos`, `mkServer`, `mkDarwin`, `mkMobile`, `mkService`,
  `mkRemoteBuilder`, `mkTsIp`, `mkJsonMerge`, `importTree`). `lib/` is
  authoritative: a helper with the same name as a nixpkgs one replaces it.
  Names must be unique across `lib/` files (not checked).
  (`perSystem` modules still get plain nixpkgs `lib`.)
- `options/`: shared option definitions, one directory per module class:
  `flake/` (`flake.hosts`, `darwinConfigurations`), `nixos/`, `darwin/`
  (ports of nixpkgs NixOS modules), `generic/` (both) and `hjem/`.
- `vars/`: flake-wide registries — `homelab.nix` (`flake.services`
  placements via `mkService`, plus `domain`/`tailnet`) and `cosmetic.nix`
  (theme, fonts, cursor).
- `modules/homelab/`: homelab service modules (`flake.modules.nixos.<name>`),
  auto-imported for the matching host by the `default` module in `mapServerModules.nix`;
  `server` is the shared headless-server bundle (passwordless wheel sudo).
- `modules/system/`: shared system modules (ssh, sops, user, networking,
  tailscale, syncthing, boot, fail2ban, battery, disko, fonts, vms,
  mobile, ...).
- `modules/cli/`, `modules/gui/`, `modules/de/`, `modules/ai/`: CLI tools,
  GUI apps, desktop environments, and AI tooling (ollama, t3code).
- `modules/nixvim/`: Neovim (nixvim) configuration.
- `modules/nix.nix`, `modules/hjem.nix`, `modules/flake-parts.nix`,
  `modules/configurations.nix`, `modules/packages/`: nix settings
  (substituters, remote builders) and cache config, hjem, flake plumbing,
  host-to-configuration wiring, and extra packages (per-system configs,
  script flake passthrough, `t3code` slim builds).
- Script flakes: the Python tools (`nhw`, `deploy-py`,
  `nixpkgs-pr-tracker`, `sports-ntfy`, `cliproxy-usage-ntfy`) each have their
  own repo on git.samtee.party with a flake exporting the package, an overlay
  and, for services, `nixosModules.default`. They are flake inputs here,
  re-exported in `modules/packages/scripts.nix`, and their modules are
  imported by the matching `modules/homelab/<name>.nix`. Push changes to the
  script repo and run `nix flake update <name>` (the nightly CI update also
  picks them up); test local edits with
  `--override-input <name> ~/projects/<name>`.
- `docs/`: generated services/hosts tables (do not edit;
  see `scripts/update-*-docs.sh`), linked from the sections above.
- `secrets.yaml` / `.sops.yaml`: sops-encrypted secrets (see below).

## Secrets

Secrets live in `secrets.yaml`, sops-encrypted with per-machine
age keys (see `.sops.yaml`). The default sops file is wired up in
`modules/system/sops.nix`.

## Binary cache

See [atticd.md](docs/atticd.md) for details on setting up the cache server
and using it from a machine before switching that machine to this config.

## Remote builders

Any host with `flake.hosts.<name>.remoteBuilder.publicHostKey` set becomes a remote build machine (via `mkRemoteBuilder` in `modules/nix.nix`). Remote Builder config is set by 
hosts.<hostname>.remoteBuilder, with options for speedFactor and maxJobs

To find the publicHostKey:

```sh
ssh-keyscan -t ed25519 <host>  | awk '/ed25519/ {print $2, $3}' | base64 -w0
```
