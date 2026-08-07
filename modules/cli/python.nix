let
  pyPkgs = pkgs:
    with pkgs; [
      python3
      ruff
      ty
      uv
    ];
in {
  flake.modules = {
    homeManager.cli = {pkgs, ...}: {
      home.packages = pyPkgs pkgs;
    };
    nixos.cli = {pkgs, ...}: {
      environment.systemPackages = pyPkgs pkgs;
    };
  };
}
