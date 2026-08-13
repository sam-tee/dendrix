{self, ...}: {
  flake.modules = {
    nixos.wm = {pkgs, ...}: {
      imports = [self.modules.nixos.noctalia];
      environment = {
        sessionVariables = {
          NIXOS_OZONE_WL = "1";
          QT_QPA_PLATFORMTHEME = "gtk3";
        };
        systemPackages = with pkgs; [
          ddcutil
          ghostty
          pavucontrol
          wl-clipboard
          xwayland-satellite
        ];
      };
      services.gnome.gnome-keyring.enable = true;
      security.polkit.enable = true;
      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-hyprland
          xdg-desktop-portal-gtk
        ];
        config.common = {
          default = ["gtk"];
          "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
        };
      };
    };
  };
}
