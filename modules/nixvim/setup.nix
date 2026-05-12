{
  inputs,
  self,
  ...
}: let
  mkNixvim = type: {
    imports = [inputs.nixvim."${type}Modules".nixvim];
    programs.nixvim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      imports = [self.modules.nixvim.default];
    };
  };
in {
  flake-file.inputs.nixvim = {
    url = "github:nix-community/nixvim";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  imports = [inputs.nixvim.flakeModules.default];
  nixvim = {
    checks.enable = true;
    packages.enable = true;
  };
  flake.modules = {
    nixos.nixvim = mkNixvim "nixos";
    homeManager.nixvim = mkNixvim "home";
    darwin.nixvim = mkNixvim "nixDarwin";
  };
  perSystem = {system, ...}: {
    nixvimConfigurations.default = inputs.nixvim.lib.evalNixvim {
      inherit system;
      modules = [self.modules.nixvim.default];
    };
  };
}
