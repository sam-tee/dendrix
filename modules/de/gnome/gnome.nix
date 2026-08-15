{
  flake.modules.nixos.gnome = {pkgs, ...}: {
    environment = {
      systemPackages =
        (with pkgs; [
          gnome-tweaks
          dconf2nix
          dconf-editor
          gnome-extension-manager
          nautilus
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
    programs.nautilus-open-any-terminal = {
      enable = true;
      terminal = "ghostty";
    };
    services = {
      desktopManager.gnome.enable = true;
      power-profiles-daemon.enable = true;
      gnome = {
        gnome-keyring.enable = true;
        sushi.enable = true;
      };
      udev.packages = [pkgs.gnome-settings-daemon];
    };
    programs.ssh.startAgent = false;
  };
}
