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
            window_focus_west = "ctrl + alt - h";
            window_focus_east = "ctrl + alt - l";
            window_focus_north = "ctrl + alt - k";
            window_focus_south = "ctrl + alt - j";
            window_swap_west = "ctrl + alt + shift - h";
            window_swap_east = "ctrl + alt + shift - l";
            window_swap_north = "ctrl + alt + shift - k";
            window_swap_south = "ctrl + alt + shift - j";
            window_center = "ctrl + alt - m";
            window_resize = "ctrl + alt - r";
            window_fullwidth = "ctrl + alt - f";
            window_manage = "ctrl + alt - v";
            window_stack = "ctrl + alt - period";
            window_unstack = "ctrl + alt - comma";
            window_nextdisplay = "ctrl + alt - tab";
            window_nextdisplaysend = "ctrl + alt + shift - tab";
          }
          // (mkBindings "ctrl + alt" "window_virtualnum")
          // (mkBindings "ctrl + alt + shift" "window_virtualmovenum");
        windows.pip = {
          title = "Picture.*(in)?.*[Pp]icture";
          floating = true;
        };
      };
    };
  };
}
