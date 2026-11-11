# Agent Notes

## Project Overview

This repository is a dendritic Nix flake for NixOS, nix-darwin,
and homelab service configuration. `flake-parts` and 
`lib/importTree.nix` load every `.nix` file under `hosts/`, `modules/`,
`options/` and `vars/` as a flake module (paths starting with `_` are
skipped), so most changes should happen there rather than in `flake.nix`.
Files under `lib/` are not flake modules: each is a function of
`{lib, inputs, self, ...}` returning helpers that are merged into `lib`, so
flake, NixOS and darwin modules call `lib.mkTsIp` etc.

Run `nix flake check` before reporting task done and fix any errors it produces.

## Hosts

See [hosts.md](docs/hosts.md) for the full table generated from
`hosts/*.nix`. `<hostname>Hardware` modules are auto-imported (and required)
for desktop and server configs; `<hostname>Disko` modules are auto-imported
when defined. All hosts are accessible via ssh thorugh tailscale.

## Services

See [services.md](docs/services.md) for the full list of services and the
ports, hosts and subdomains they run on, generated from `vars/homelab.nix`.
To add a service, add entry to the registry and add module to `modules/homelab/<name>`.
The module will be auto-imported to the host. Option sets should be defined in
`options/<class>/<name>`.

## Conventions

- Use structured Nix modules and existing options instead of hard-coded service
  snippets when a local module already exists.
- Keep reusable service logic in the relevant shared module directory.
- Secrets are managed through `sops-nix`; the secrets file is
  `secrets.yaml`, encrypted with age and committed to this repo
  (see `.sops.yaml` for recipients). Do not edit secrets directly, instead inform the user what to change.
- Scope `lib` as narrowly as possible: take it as an arg of the innermost
  module (or `perSystem`) that uses it, with a single `inherit (lib) …;`
  (plus `inherit (lib.types) …;`) in that scope, and use the bare names.
  Only hoist `lib` to file scope when multiple sibling scopes use it, so
  the file still has just one import. A single `lib.foo` use needs no
  `inherit`.

## Useful Commands

Commands are defined in [commands.md](docs/commands.md), covering host deploys, flake checks,
and reading CI logs (`scripts/ci-logs.sh`; CI runs on Forgejo, not GitHub).
