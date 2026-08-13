{
  inputs,
  lib,
  self,
  ...
}: {
  flake-file.inputs.paneru = {
    url = "github:karinushka/paneru";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.darwin.paneru = _: {
    imports = [
      inputs.paneru.darwinModules.paneru
      self.modules.darwin.skhd
    ];
    services.paneru = {
      enable = true;
      settings = {
        options = {
          focus_follows_mouse = true;
          mouse_follows_focus = true;
          preset_column_widths = [0.5];
          menubar_height = 0;
          auto_center = true;
        };
        decorations.workspace_popup_status = false;
        swipe = {
          continuous = false;
          gesture.fingers_count = 3;
        };
        padding = lib.genAttrs ["left" "right" "top" "bottom"] (_: 0);
        bindings = let
          mkBindings = prefix: command:
            lib.range 1 9
            |> map (i: lib.nameValuePair "${command}_${toString i}" "${prefix} - ${toString i}")
            |> builtins.listToAttrs;
        in
          {
            window_focus_west = "ctrl + cmd - h";
            window_focus_east = "ctrl + cmd - l";
            window_focus_north = "ctrl + cmd - j";
            window_focus_south = "ctrl + cmd - k";
            window_swap_west = "ctrl + cmd + shift - h";
            window_swap_east = "ctrl + cmd + shift - l";
            window_swap_north = "ctrl + cmd + shift - k";
            window_swap_south = "ctrl + cmd + shift - j";
            window_center = "ctrl + cmd - m";
            window_resize = "ctrl + cmd - r";
            window_fullwidth = "ctrl + cmd - f";
            window_manage = "ctrl + cmd - v";
            window_stack = "ctrl + cmd - period";
            window_unstack = "ctrl + cmd - comma";
            window_nextdisplay = "ctrl + cmd - tab";
            window_nextdisplaysend = "ctrl + cmd + shift - tab";
          }
          // (mkBindings "ctrl" "window_virtualnum")
          // (mkBindings "ctrl + shift" "window_virtualmovenum");
        windows.pip = {
          title = "Picture.*(in)?.*[Pp]icture";
          floating = true;
        };
      };
    };
  };
}
