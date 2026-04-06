{
  flake.modules.homeManager.hyprTouch = {pkgs, ...}: {
    home.packages = with pkgs; [wvkbd];
    wayland.windowManager.hyprland = {
      plugins = [(pkgs.callPackage ./_hyprgrass.nix {})];
      settings = {
        exec-once = ["wvkbd-mobintl"];
        plugin.touch_gestures = {
          sensitivity = 3.0;
          workspace_swipe_fingers = 3;
          workspace_swipe_edge = "";
          resize_on_border_long_press = true;
          hyprgrass-bind = [
            ", edge:d:u, exec, kill -34 $(ps -C wvkbd-mobintl)"
            ", tap:3, exec, $noctalia launcher toggle"
            ", swipe:4:d, killactive"
          ];
        };
      };
    };
  };
}
