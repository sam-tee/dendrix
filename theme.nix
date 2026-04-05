let
  theme = fromTOML (builtins.readFile ./modules/cosmetic/theme.toml);
  pkgs = import <nixpkgs> {};
  lib = pkgs.lib;
  filtered = (lib.filterAttrs (name: _: lib.hasPrefix "base" name)) theme;
in
  (builtins.mapAttrs (name: value: lib.removePrefix "#" value)) theme
