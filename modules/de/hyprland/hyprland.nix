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
          cursor = [{no_hardware_cursors = true;}];
          env = ["QT_QPA_PLATFORMTHEME,qt6ct"];
          general = {
            border_size = 1;
            gaps_in = 0;
            gaps_out = 0;
            "col.active_border" = "rgb(${base03})";
            "col.inactive_border" = "rgb(${base03})";
          };
          animations.enabled = false;
          exec-once = ["noctalia-shell" "bitwarden"];
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
