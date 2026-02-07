{
  flake.modules.homeManager.gtk = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.fonts.fontconfig.defaultFonts;
  in {
    gtk = {
      enable = true;
      theme = {
        package = pkgs.adw-gtk3;
        name = "adw-gtk3-dark";
      };
      iconTheme = {
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
      };
      font = {
        name = lib.head cfg.sansSerif;
        size = 11;
      };
    };
  };
}
