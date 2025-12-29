let
  pyPkgs = pkgs:
    with pkgs; [
      python3
      ruff
      ty
    ];
in {
  flake.modules.nixos.cli = {pkgs, ...}: {
    environment.systemPackages = pyPkgs pkgs;
  };
  flake.modules.darwin.cli = {pkgs, ...}: {
    environment.systemPackages = pyPkgs pkgs;
  };
  flake.modules.homeManager.cli = {pkgs, ...}: {
    home.packages = pyPkgs pkgs;
  };
}
