{
  flake-file.inputs.paneru = {
    url = "github:karinushka/paneru";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake.modules.homeManager.paneru = {inputs, ...}: {
    imports = [inputs.paneru.homeModules.paneru];
    services.paneru = {
      enable = true;
      settings = {
        options = {
          focus_follows_mouse = true;
          preset_column_widths = [
            0.33
            0.5
            0.66
          ];
          swipe_gesture_fingers = 4;
          swipe_gesture_direction = "Natural";
        };
        bindings = {
          window_focus_west = "ctrl - h";
          window_focus_east = "ctrl - l";
          window_focus_north = "ctrl - k";
          window_focus_south = "ctrl - j";
          window_swap_west = "ctrl + shift - h";
          window_swap_east = "ctrl + shift - l";
          window_center = "ctrl - m";
          window_resize = "ctrl - r";
          window_fullwidth = "ctrl - f";
          window_manage = "ctrl + alt - t";
          window_stack = "ctrl - ]";
          window_unstack = "ctrl + shift - ]";
        };
        windows.pip = {
          title = "Picture.*(in)?.*[Pp]icture";
          floating = true;
        };
      };
    };
  };
}
