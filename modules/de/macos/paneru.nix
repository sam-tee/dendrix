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

  flake.modules.homeManager.paneru = _: {
    imports = [
      inputs.paneru.homeModules.paneru
      self.modules.homeManager.skhd
    ];
    services.paneru = {
      enable = true;
      settings = {
        options = {
          focus_follows_mouse = true;
          mouse_follows_focus = true;
          preset_column_widths = [0.5];
          menubar_height = 0;
        };
        decorations.workspace_popup_status = false;
        swipe = {
          continuous = true;
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
            window_manage = "ctrl - v";
            window_stack = "ctrl - period";
            window_unstack = "ctrl - comma";
            window_nextdisplay = "ctrl - tab";
            window_nextdisplaysend = "ctrl + shift - tab";
            mouse_nextdisplay = "ctrl + alt - tab";
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
