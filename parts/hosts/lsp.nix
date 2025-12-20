# dummy hosts for use with nixd lsp to provide options
{inputs, ...}: {
  flake = {
    darwinConfigurations."lsp" = inputs.nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [{system.stateVersion = 6;}];
    };
    nixosConfigurations."lsp" = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [];
    };
    homeConfigurations."lsp" = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
      modules = [
        {
          home = {
            stateVersion = "25.05";
            username = "lsp";
            homeDirectory = "/home/sam";
          };
        }
      ];
    };
  };
}
