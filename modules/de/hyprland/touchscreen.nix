{
  flake.modules.homeManager.hyprTouch = {pkgs, ...}: let
    toggleKeyboard = pkgs.writeShellScriptBin "toggle-keyboard" ''
      if pgrep -x "wvkbd" > /dev/null
      then
        pkill -x "wvkbd"
      else
        ${pkgs.wvkbd}/bin/wvkbd-mobintl &
      fi
    '';
  in {
    home.packages = with pkgs; [
      wvkbd
      toggleKeyboard
    ];
    wayland.windowManager.hyprland = {
      plugins = [(pkgs.callPackage ./_hyprgrass.nix {})];
      settings.plugin.touch_gestures = {
        sensitivity = 1.0;
        workspace_swipe_fingers = 3;
        workspace_swipe_edge = "";
        resize_on_border_long_press = true;
        hyprgrass-bind = [
          ", edge:b:u, exec, ${toggleKeyboard}/bin/toggle-keyboard"
          ", tap:3, exec, $noctalia launcher toggle"
          ", swipe:4:d, killactive"
        ];
      };
    };
  };
}
