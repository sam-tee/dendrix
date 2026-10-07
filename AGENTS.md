# Agent Notes

## Project Overview

This repository is a dendritic Nix flake for NixOS, nix-darwin,
and homelab service configuration. `flake-parts` and `import-tree` load files
under `modules/` as flake modules, so most changes should happen in `modules/`
rather than in the generated root flake.

## Conventions

- Host files define `flake.hosts.<hostname>` metadata (including `hostType`
  and a `modules` list of shared `flake.modules` names). `mkConfig`
  auto-generates each configuration via the matching builder (`mkServer`,
  `mkNixos`, `mkDarwin`, or `mkMobile`); host-specific bits (hardware,
  disk, `<hostname>` tweaks) live in further `flake.modules` entries.
  Desktop/server hosts must define `<hostname>Hardware` (asserted and
  auto-imported by `mkNixosModules`); the current table is in `docs/hosts.md`.
- Use structured Nix modules and existing options instead of hard-coded service
  snippets when a local module already exists.
- Keep hardware, disk, and host-specific config in `modules/hosts/`.
- Keep reusable service logic in `modules/homelab/`, `modules/system/`,
  `modules/gui/`, `modules/cli/`, or the relevant shared module directory.
- Secrets are managed through `sops-nix`; the secrets file is
  `nix-secrets/secrets.yaml`, encrypted with age and committed to this repo
  (see `nix-secrets/.sops.yaml` for recipients). Do not edit secrets directly, instead inform the user what to change.
- For new services: register the placement with `mkService <host> <port>
  <subdomain>` in `modules/vars/homelab.nix` (`flake.services.<name>`), and
  implement `flake.modules.nixos.<name>` in `modules/homelab/<name>.nix`
  using `self.services.<name>` plus `config.homelab` (user/group, `dataDir`,
  bind IPs); it is auto-imported on the registered host (see
  `modules/homelab/mapServerModules.nix`). Only custom daemons needing new NixOS
  options define `options.services.<name>` (e.g. `sports-ntfy` in
  `modules/options/`).

## Useful Commands

Commands are defined in [commands.md](docs/commands.md), covering host deploys and flake checks.

## Machine Access

Hosts are defined in [hosts.md](docs/hosts.md) and accessible over SSH using their hostname.

## Homelab Services

Services are defined in [services.md](docs/services.md), which is programmatically generated from the flake.
