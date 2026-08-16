{
  lib,
  self,
  ...
}: let
  configs = self.nixosConfigurations // self.darwinConfigurations;
in {
  flake.packages = lib.mapAttrs (
    _: names: lib.genAttrs names (name: configs.${name}.config.system.build.toplevel)
  ) (lib.groupBy (name: configs.${name}.pkgs.stdenv.hostPlatform.system) (builtins.attrNames configs));
}
