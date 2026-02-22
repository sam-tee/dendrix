{
  flake.modules = {
    nixos = {
      hyprlandHM = {inputs, ...}: {
        imports = with inputs.self.modules.nixos; [
          hm
          hyprland
          noctalia
        ];
        home-manager.sharedModules = with inputs.self.modules.homeManager; [
          hyprland
          noctalia
        ];
      };
      hyprland = {pkgs, ...}: {
        environment = {
          sessionVariables.NIXOS_OZONE_WL = "1";
          systemPackages =
            (with pkgs; [
              ghostty
              hyprpaper
              hyprshot
              hyprpolkitagent
              sddm-sugar-dark
              wl-clipboard
            ])
            ++ (with pkgs.kdePackages; [
              dolphin
              kwallet
              kwallet-pam
              kwalletmanager
              sddm-kcm
            ]);
        };
        programs = {
          hyprland = {
            enable = true;
            withUWSM = true;
            xwayland.enable = true;
          };
          hyprlock.enable = true;
        };
        security.pam.services.login.kwallet.enable = true;
        services = {
          displayManager.sddm = {
            enable = true;
            wayland.enable = true;
            theme = "sugar-dark";
          };
          hypridle.enable = true;
        };
        xdg.portal = {
          enable = true;
          extraPortals = with pkgs; [
            xdg-desktop-portal-hyprland
            xdg-desktop-portal-gtk
          ];
          config.common.default = ["gtk"];
        };
      };
    };
    homeManager.hyprland = {
      config,
      lib,
      ...
    }: {
      programs.hyprshot.enable = true;
      services = {
        hyprpolkitagent.enable = true;
      };
      wayland.windowManager.hyprland = {
        enable = true;
        systemd.enable = false;
        settings = {
          env = ["QT_QPA_PLATFORMTHEME,qt6ct"];
          monitor = config.hypr.monitors;
          general = lib.genAttrs ["gaps_in" "gaps_out" "border_size"] (_: 0);
          animations.enabled = false;
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
