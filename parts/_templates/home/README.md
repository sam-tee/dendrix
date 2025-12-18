# Opinionated home-manager config
## Akhlus Modules

Uses the home modules at https://github.com/akhlus/nix to provide a default config. Use `nix inputs.nix-akhlus.homeModules.default` for options that apply across all systems or `nix inputs.nix-akhlus.homeModules.default` for the cross-system modules plus DE configuration options for gnome and kde. Custom options are exposed under the hMods attrset.

## Flatpak

The flake by default includes flatpaks through nix-flatpak. Further options can be found at https://github.com/gmodena/nix-flatpak

## NixGL

NixGL is included by default to provide hardware acceleration for non-nixos systems. Use `nix config.lib.nixGL.wrap` to get a wrapped version of a nix package. See https://github.com/nix-community/nixgl for further config
