{
  description = "A simple LaTeX template for writing documents with latexmk";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
      perSystem = {pkgs, ...}: let
        latexScript = extraArgs: name:
          pkgs.writeShellScriptBin name ''
            if [ -z "$1" ]; then
                echo "Error no file name provided"
                echo "Usage: ${name} <filename>"
                exit 1
            fi
            mkdir -p .cache/latex
            ${pkgs.texliveFull}/bin/latexmk -pvc -pdf -interaction=nonstopmode -auxdir=.cache/latex -synctex=1 ${extraArgs} "$1"
          '';
        watchScript = latexScript "-pvc -synctex=1" "watch-tex";
        compileScript = latexScript "" "compile-tex";
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            compileScript
            watchScript
            texliveFull
          ];
        };
      };
    };
}
