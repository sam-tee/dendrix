{
  flake.modules = {
    nixos.cli = {pkgs, ...}: {
      environment.systemPackages = [pkgs.btop];
    };
    darwin.cli = {pkgs, ...}: {
      environment.systemPackages = [pkgs.btop];
    };
    homeManager.cli = _: {
      programs.btop = {
        enable = true;
        settings.theme_background = false;
      };
    };
  };
}
