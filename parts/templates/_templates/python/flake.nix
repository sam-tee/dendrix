{
  description = "A simple Python development flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        pythonEnv = pkgs.python3.withPackages (p:
          with p; [
            #python modules go here
          ]);
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            #basedpyright
            pythonEnv
            ruff
            ty
            #uv
          ];
          shellHook = ''
            export PATH=${pythonEnv}/bin:$PATH
            export PYTHONPATH=${pythonEnv}/${pkgs.python3.sitePackages}:$PYTHONPATH
          '';
        };
      }
    );
}
