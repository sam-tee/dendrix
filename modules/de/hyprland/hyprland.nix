{
  flake.modules = {
    nixos = {
      hyprlandHM = {inputs, ...}: {
        imports = with inputs.self.modules.nixos; [
          hm
          hyprland
          noctalia
          sddm
        ];
        home-manager.sharedModules = with inputs.self.modules.homeManager; [
          hyprland
          noctalia
        ];
      };
      hyprland = {pkgs, ...}: {
        environment = {
          sessionVariables.NIXOS_OZONE_WL = "1";
          systemPackages = with pkgs; [
            ghostty
            hyprshot
            hyprpolkitagent
            wl-clipboard
            kdePackages.dolphin
            sddm-astronaut
          ];
        };
        programs = {
          hyprland = {
            enable = true;
            withUWSM = true;
            xwayland.enable = true;
          };
        };
        services.gnome.gnome-keyring.enable = true;
        xdg.portal = {
          enable = true;
          extraPortals = with pkgs; [
            xdg-desktop-portal-hyprland
            xdg-desktop-portal-gtk
          ];
          config.common = {
            default = ["gtk"];
            "org.freedesktop.impl.portal.ScreenCast" = ["hyprland"];
            "org.freedesktop.impl.portal.Screenshot" = ["hyprland"];
          };
        };
      };
    };
    homeManager.hyprland = {
      config,
      lib,
      ...
    }: {
      programs.hyprshot.enable = true;
      services.hyprpolkitagent.enable = true;
      wayland.windowManager.hyprland = {
        enable = true;
        systemd.enable = false;
        settings = {
          env = ["QT_QPA_PLATFORMTHEME,qt6ct"];
          monitor = config.hypr.monitors;
          general = lib.genAttrs ["gaps_in" "gaps_out" "border_size"] (_: 0);
          animations.enabled = false;
          exec-once = ["noctalia-shell"];
          workspace = map (
            i: "${toString (i + 1)}, persistent:true"
          ) (builtins.genList (i: i) 9);
          input = {
            kb_layout = "gb";
            kb_options = "caps:escape";
            touchpad.natural_scroll = true;
          };
        };
      };
    };
  };
}
