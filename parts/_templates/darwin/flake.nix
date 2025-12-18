{
  description = "Darwin system configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-akhlus = {
      url = "github:akhlus/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs @ {...}: let
    hostname = "HOSTNAME";
    username = "USERNAME";
  in {
    darwinConfigurations.${hostname} = inputs.nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = {inherit inputs hostname username;};
      modules = [
        inputs.nix-akhlus.darwinModules.default
        ./_darwin.nix
      ];
    };
  };
}
