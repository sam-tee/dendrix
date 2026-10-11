{
  inputs,
  self,
  ...
}: let
  mkNixvim = type: {
    imports = [inputs.nixvim."${type}Modules".nixvim];
    programs.nixvim = {
      enable = true;
      nixpkgs.useGlobalPackages = true;
      viAlias = true;
      vimAlias = true;
      imports = [self.modules.nixvim.default];
    };
  };
in {
  imports = [inputs.nixvim.flakeModules.default];
  nixvim = {
    checks.enable = true;
    packages.enable = true;
  };
  flake.modules = {
    nixos.nixvim = mkNixvim "nixos";
    nixos.default = self.modules.nixos.nixvim;
    darwin.nixvim = mkNixvim "nixDarwin";
    darwin.default = self.modules.darwin.nixvim;
  };
  perSystem = {system, ...}: {
    nixvimConfigurations.default = inputs.nixvim.lib.evalNixvim {
      inherit system;
      modules = [
        self.modules.nixvim.default
        {nixpkgs.source = inputs.nixpkgs;}
      ];
    };
  };
}
