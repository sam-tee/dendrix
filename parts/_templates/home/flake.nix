{
  description = "Home-manager flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-akhlus = {
      url = "github:akhlus/nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    nixgl.url = "github:nix-community/nixGL";
  };
  outputs = inputs @ {...}: let
    system = "SYSTEM";
    username = "sam";
  in {
    homeConfigurations.${username} = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      extraSpecialArgs = {inherit inputs username;};
      modules = [
        inputs.nix-akhlus.homeModules.default
        ./_home.nix
        inputs.nix-flatpak.homeManagerModules.nix-flatpak
      ];
    };
  };
}
