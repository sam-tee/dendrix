{
  lib,
  self,
  ...
}: {
  perSystem = {system, ...}: let
    allConfigurations =
      self.nixosConfigurations
      // self.darwinConfigurations;
  in {
    packages =
      allConfigurations
      |> lib.filterAttrs (_: config: config.pkgs.stdenv.hostPlatform.system == system)
      |> lib.mapAttrs (_: config: config.config.system.build.toplevel);
  };
}
