{
  flake.modules.homeManager.cli = {pkgs, ...}: {
    home.packages = with pkgs; [
      python3
      ruff
      ty
      uv
    ];
  };
}
