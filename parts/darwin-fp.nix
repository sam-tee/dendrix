{
  flake-parts-lib,
  lib,
  ...
}: let
  inherit (lib) mkOption types;
in {
  options = {
    flake = flake-parts-lib.mkSubmoduleOptions {
      darwinConfigurations = mkOption {
        type = types.lazyAttrsOf types.raw;
        default = {};
        description = "Instantiated Darwin configurations";
      };
    };
  };
}
