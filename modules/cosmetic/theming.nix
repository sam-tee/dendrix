{self, ...}: {
  flake.modules.homeManager.theming = {pkgs, ...}: {
    qt = let
      qtctSettings = {
        Appearance = {
          custom_palette = true;
          standard_dialogs = "default";
          style = "kvantum";
        };
        Fonts = {
          fixed = ''"${self.cosmetic.fonts.mono.name},${toString self.cosmetic.fonts.size}"'';
          general = ''"${self.cosmetic.fonts.ui.name},${toString self.cosmetic.fonts.size}"'';
        };
      };
    in {
      enable = true;
      platformTheme.name = "qtct";
      style.name = "kvantum";
      qt5ctSettings = qtctSettings;
      qt6ctSettings = qtctSettings;
    };
    dconf = {
      enable = true;
      settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
    };
    xdg.configFile = let
      css = import ./_gtkCss.nix self.cosmetic.theme.attrs;
    in {
      "gtk-3.0/gtk.css".text = css;
      "gtk-4.0/gtk.css".text = css;
    };
    gtk = let
      colorScheme = "dark";
      theme = {
        package = pkgs.adw-gtk3;
        name = "adw-gtk3";
      };
    in {
      enable = true;
      inherit colorScheme theme;
      gtk4.theme = null;
      iconTheme = {
        name = "Adwaita";
        package = pkgs.adwaita-icon-theme;
      };
    };
  };
}
