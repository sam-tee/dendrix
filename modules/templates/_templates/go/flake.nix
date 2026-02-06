{
  description = "Go development flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFLake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
      perSystem = {pkgs, ...}: {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            go
            gopls
            gotools
            go-tools
          ];
        };
      };
    };
}
