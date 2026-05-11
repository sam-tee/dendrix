{
  inputs,
  self,
  ...
}: {
  flake-file.inputs.nixvim = {
    url = "github:nix-community/nixvim";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  imports = [inputs.nixvim.flakeModules.default];
  nixvim = {
    checks.enable = true;
    packages.enable = true;
  };
  perSystem = {system, ...}: {
    nixvimConfigurations.default = inputs.nixvim.lib.evalNixvim {
      inherit system;
      modules = [self.modules.nixvim.default];
    };
  };
}
