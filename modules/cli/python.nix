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
