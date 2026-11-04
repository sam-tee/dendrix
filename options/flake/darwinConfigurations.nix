{lib, ...}: let
  inherit (lib) mkOption;
  inherit (lib.types) lazyAttrsOf raw;
in {
  options.flake.darwinConfigurations = mkOption {
    type = lazyAttrsOf raw;
    default = {};
    description = "Instantiated Darwin configurations";
  };
}
