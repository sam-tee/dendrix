{
  description = "A nixos flake using unstable";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-akhlus = {
      url = "github:akhlus/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mobile-nixos = {
      url = "github:mobile-nixos/mobile-nixos";
      flake = false;
    };
  };
  outputs = inputs @ {...}: let
    hostname = "HOSTNAME";
    username = "USERNAME";
    device = "DEVICE";
    system = "aarch64-linux";
  in {
    nixosConfigurations.${hostname} = inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {inherit inputs hostname username;};
      modules = [
        (import "${inputs.mobile-nixos}/lib/configuration.nix" {inherit device;})
        inputs.nix-akhlus.nixosModules.all
        ./nixos.nix
      ];
    };
    homeConfigurations.${username} = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      extraSpecialArgs = {inherit inputs username;};
      modules = [
        inputs.nix-akhlus.homeModules.all
        ./home.nix
      ];
    };
  };
}
