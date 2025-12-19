{
  flake.modules.nixos.cli = {pkgs, ...}: {
    environment.systemPackages = [pkgs.btop];
  };
  flake.modules.darwin.cli = {pkgs, ...}: {
    environment.systemPackages = [pkgs.btop];
  };
  flake.modules.homeManager.cli = {config, ...}: let
    theme = config.cosmetic.theme;
  in {
    programs.btop = {
      enable = true;
      settings = {
        color_theme = "akhlus";
        theme_background = false;
      };
      themes = import ./_themes.nix theme;
    };
  };
}
