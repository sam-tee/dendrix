{self, ...}: {
  perSystem = {
    system,
    lib,
    ...
  }: let
    inherit (lib) filterAttrs mapAttrs;
    allConfigurations =
      self.nixosConfigurations
      // self.darwinConfigurations;
  in {
    packages =
      allConfigurations
      |> filterAttrs (_: config: config.pkgs.stdenv.hostPlatform.system == system)
      |> mapAttrs (_: config: config.config.system.build.toplevel);
  };
}
