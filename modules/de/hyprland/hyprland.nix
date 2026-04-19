{self, ...}: let
  inherit (self.cosmetic.theme.noHash) base03;
in {
  flake.modules = {
    nixos.hyprland = _: {
      imports = with self.modules.nixos; [
        sddm
        wm
      ];
      home-manager.sharedModules = with self.modules.homeManager; [
        hyprland
      ];
      programs = {
        hyprland = {
          enable = true;
          withUWSM = true;
          xwayland.enable = true;
        };
      };
    };
    homeManager.hyprland = _: {
      wayland.windowManager.hyprland = {
        enable = true;
        systemd.enable = false;
        settings = {
          cursor.no_hardware_cursors = true;
          general = {
            border_size = 1;
            gaps_in = 0;
            gaps_out = 0;
            "col.active_border" = "rgb(${base03})";
            "col.inactive_border" = "rgb(${base03})";
          };
          windowrule = [
            {
              name = "browser-pip";
              "match:title" = "^(Picture-in-[Pp]icture)$";
              float = 1;
              pin = 1;
              size = "368 207";
              move = "(monitor_w-window_w) (monitor_h-window_h)";
            }
            {
              name = "fullscreen inhibit idle";
              "match:class" = ".*";
              idle_inhibit = "fullscreen";
            }
          ];
          animations.enabled = false;
          exec-once = ["noctalia-shell" "bitwarden"];
          workspace = map (
            i: "${toString (i + 1)}, persistent:true"
          ) (builtins.genList (i: i) 9);
          misc = {
            disable_hyprland_logo = true;
            disable_splash_rendering = true;
          };
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
