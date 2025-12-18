{
  description = "A nixos flake using unstable";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-akhlus = {
      url = "github:akhlus/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs @ {...}: let
    hostname = "HOSTNAME";
    username = "USERNAME";
    system = "SYSTEM";
  in {
    nixosConfigurations.${hostname} = inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {inherit inputs hostname username;};
      modules = [
        inputs.nix-akhlus.nixosModules.all
        ./nixos.nix
        ./hardware.nix
      ];
    };
  };
}
