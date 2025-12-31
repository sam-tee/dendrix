{
  flake.modules.nixos.cli = {pkgs, ...}: {
    environment.systemPackages = [pkgs.btop];
  };
  flake.modules.darwin.cli = {pkgs, ...}: {
    environment.systemPackages = [pkgs.btop];
  };
  flake.modules.homeManager.cli = {config, ...}: {
    programs.btop = {
      enable = true;
      settings = {
        color_theme = "akhlus";
        theme_background = false;
      };
      themes = import ./_themes.nix config.cosmetic.themes;
    };
  };
}
