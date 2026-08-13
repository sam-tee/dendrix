{
  moduleWithSystem,
  self,
  ...
}: {
  flake-file.inputs.helium = {
    url = "github:amaanq/helium-flake";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake.modules = {
    darwin.default = self.modules.generic.helium;
    nixos.gui = self.modules.generic.helium;
    generic.helium = moduleWithSystem ({inputs', ...}: {...}: {
      environment.systemPackages = [inputs'.helium.packages.default];
    });
  };
}
