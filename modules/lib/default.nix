{
  flake-parts-lib,
  lib,
  ...
}: let
  inherit (lib) types mkOption;
  inherit (types) attrsOf lazyAttrsOf raw;
in {
  options.flake = flake-parts-lib.mkSubmoduleOptions {
    darwinConfigurations = mkOption {
      type = lazyAttrsOf raw;
      default = {};
      description = "Instantiated Darwin configurations";
    };
    lib = mkOption {type = attrsOf raw;};
  };
}
