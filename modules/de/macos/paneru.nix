{
  inputs,
  lib,
  ...
}: {
  flake-file.inputs.paneru = {
    url = "github:karinushka/paneru";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake.modules.homeManager.paneru = _: let
    mkPadding = keys: lib.genAttrs keys (_: 0);
    mkBindings = prefix: command:
      lib.range 1 9
      |> map (i: lib.nameValuePair "${command}_${toString i}" "${prefix} - ${toString i}")
      |> builtins.listToAttrs;
  in {
    imports = [inputs.paneru.homeModules.paneru];
    services.paneru = {
      enable = true;
      settings = {
        options = {
          focus_follows_mouse = true;
          mouse_follows_focus = true;
          preset_column_widths = [
            0.33
            0.5
            0.66
          ];
          swipe_gesture_fingers = 4;
          swipe_gesture_direction = "Natural";
        };
        padding = mkPadding ["left" "right" "top" "bottom"];
        bindings =
          {
            window_focus_west = "ctrl - h";
            window_focus_east = "ctrl - l";
            window_focus_north = "ctrl - k";
            window_focus_south = "ctrl - j";
            window_swap_west = "ctrl + shift - h";
            window_swap_east = "ctrl + shift - l";
            window_swap_north = "ctrl + shift - k";
            window_swap_south = "ctrl + shift - j";
            window_center = "ctrl - m";
            window_resize = "ctrl - r";
            window_fullwidth = "ctrl - f";
            window_manage = "ctrl + alt - t";
            window_stack = "ctrl - comma";
            window_unstack = "ctrl - slash";
          }
          // (mkBindings "ctrl" "window_virtualnum")
          // (mkBindings "ctrl + shift" "window_virtualmovenum");
        windows = {
          ghostty = {
            title = ".*";
            bundle_id = "com.mitchellh.ghostty";
            floating = false;
          };
          pip = {
            title = "Picture.*(in)?.*[Pp]icture";
            floating = true;
          };
        };
      };
    };
  };
}
