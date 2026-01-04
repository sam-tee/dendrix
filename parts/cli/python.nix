let
  pyPkgs = pkgs:
    with pkgs; [
      python3
      ruff
      ty
    ];
in {
  flake.modules = {
    nixos.cli = {pkgs, ...}: {
      environment.systemPackages = pyPkgs pkgs;
    };
    darwin.cli = {pkgs, ...}: {
      environment.systemPackages = pyPkgs pkgs;
    };
    homeManager.cli = {pkgs, ...}: {
      home.packages = pyPkgs pkgs;
    };
  };
}
