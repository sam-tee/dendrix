{
  flake.modules = {
    nixos = {
      niriHM = {inputs, ...}: {
        imports = with inputs.self.modules.nixos; [
          hm
          niri
          noctalia
        ];
        home-manager.sharedModules = with inputs.self.modules.homeManager; [
          niri
          noctalia
        ];
      };
      niri = {pkgs, ...}: {
        programs.niri = {
          enable = true;
          useNautilus = false;
        };
        security.polkit.enable = true;
        services = {
          gnome.gnome-keyring.enable = true;
        };
        xdg.portal = {
          enable = true;
          extraPortals = with pkgs; [xdg-desktop-portal];
          config.niri."org.freedesktop.impl.portal.FileChooser" = ["kde"];
        };
      };
    };
  };
}
