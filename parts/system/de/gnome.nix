{
  flake.modules.nixos.gnome = {pkgs, ...}: {
    environment = {
      systemPackages =
        (with pkgs; [
          gnome-tweaks
          dconf2nix
          dconf-editor
          gnome-extension-manager
        ])
        ++ (with pkgs.gnomeExtensions; [
          appindicator
          blur-my-shell
          caffeine
          clipboard-indicator
          dash-to-dock
          dash-to-panel
          tiling-shell
        ]);
      gnome.excludePackages = with pkgs; [
        gnome-backgrounds
        totem
      ];
    };
    qt = {
      enable = true;
      platformTheme = "gnome";
      style = "adwaita-dark";
    };
    services = {
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      power-profiles-daemon.enable = true;
      gnome.gnome-keyring.enable = true;
      udev.packages = [pkgs.gnome-settings-daemon];
    };
  };
}
