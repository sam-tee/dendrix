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
      hyprland = {pkgs, ...}: {
        environment = {
          sessionVariables.NIXOS_OZONE_WL = "1";
          systemPackages = with pkgs; [
            brightnessctl
            kdePackages.dolphin
            ghostty
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
        services = {
          displayManager.sddm.enable = true;
          blueman.enable = true;
          hypridle.enable = true;
        };
        xdg.portal = {
          enable = true;
          extraPortals = with pkgs; [xdg-desktop-portal-hyprland];
        };
      };
    };
    homeManager.hyprland = {config, ...}: {
      programs.hyprshot.enable = true;
      services = {
        hyprpaper = {
          enable = true;
          settings = let
            bgPath = "~/${config.cosmetic.backgroundPath}";
          in {
            preload = [bgPath];
            wallpaper = [",${bgPath}"];
          };
        };
        hyprpolkitagent.enable = true;
        mako.enable = true;
      };
      wayland.windowManager.hyprland = {
        enable = true;
        settings = {
          "$mod" = "SUPER";
          "$terminal" = "ghostty";
          "$fileManager" = "dolphin --new-window";
          "$browser" = "brave --new-window --ozone-platform=wayland";
          "$passwordManager" = "bitwarden";
          "$webapp" = "$browser --app";
        };
      };
    };
  };
}
