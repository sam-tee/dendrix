{
  flake.modules = {
    nixos.hyprland = {inputs, ...}: {
      imports = with inputs.self.modules.nixos; [
        sddm
        wm
      ];
      home-manager.sharedModules = with inputs.self.modules.homeManager; [
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
    homeManager.hyprland = {
      config,
      lib,
      pkgs,
      ...
    }: {
      wayland.windowManager.hyprland = {
        enable = true;
        systemd.enable = false;
        plugins = [pkgs.hyprlandPlugins.hyprgrass];
        settings = {
          env = ["QT_QPA_PLATFORMTHEME,qt6ct"];
          monitor = config.hypr.monitors;
          general = lib.genAttrs ["gaps_in" "gaps_out" "border_size"] (_: 0);
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
