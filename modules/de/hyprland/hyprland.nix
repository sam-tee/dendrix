{
  flake.modules = {
    nixos = {
      hyprlandHM = {inputs, ...}: {
        imports = with inputs.self.modules.nixos; [
          hm
          hyprland
        ];
        home-manager.sharedModules = [inputs.self.modules.homeManager.hyprland];
      };
      hyprland = {
        pkgs,
        username,
        ...
      }: {
        environment = {
          sessionVariables.NIXOS_OZONE_WL = "1";
          systemPackages = with pkgs; [
            brightnessctl
            kdePackages.dolphin
            ghostty
            hyprpaper
            hyprshot
            hyprpolkitagent
            pamixer
            playerctl
            pavucontrol
            waybar
            wl-clipboard
            wofi
          ];
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
          displayManager = {
            sddm = {
              enable = true;
              wayland.enable = true;
            };
            autoLogin = {
              enable = true;
              user = username;
            };
          };
          blueman.enable = true;
          hypridle.enable = true;
        };
        xdg.portal = {
          enable = true;
          extraPortals = with pkgs; [xdg-desktop-portal-hyprland];
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
        hyprpaper = {
          enable = true;
          settings = {
            splash = false;
            wallpaper = [
              {
                monitor = "";
                path = "~/${config.cosmetic.backgroundPath}";
              }
            ];
          };
        };
        hyprpolkitagent.enable = true;
        mako.enable = true;
      };
      wayland.windowManager.hyprland = {
        enable = true;
        systemd.enable = false;
        settings = {
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
