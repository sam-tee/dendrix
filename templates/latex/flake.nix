{
  description = "A simple LaTeX template for writing documents with latexmk";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    flake-utils,
    nixpkgs,
    self,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      watchScript = pkgs.writeShellScriptBin "watch-tex" ''
        if [ -z "$1" ]; then
            echo "Error no file name provided"
            echo "Usage: watch-tex <filename>"
            exit 1
        fi

        ${pkgs.latexmk}/bin/latexmk -pvc -pdf -interaction=nonstopmode -synctex=1 "$1"
      '';
      compileScript = pkgs.writeShellScriptBin "compile-tex" ''
        if [ -z "$1" ]; then
            echo "Error no file name provided"
            echo "Usage: watch-tex <filename>"
            exit 1
        fi

        ${pkgs.latexmk}/bin/latexmk -pvc -pdf "$1"
      '';
    in {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          compileScript
          watchScript
          texliveFull
        ];
      };
    });
}
