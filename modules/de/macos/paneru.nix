{inputs, ...}: {
  flake.modules.darwin.paneru = {
    config,
    lib,
    ...
  }: let
    inherit (lib) concatStringsSep genAttrs nameValuePair range;
    super = concatStringsSep " + " config.keybinds.super;
  in {
    imports = [inputs.paneru.darwinModules.paneru];
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
        padding = genAttrs ["left" "right" "top" "bottom"] (_: 0);
        bindings = let
          mkBindings = prefix: command:
            range 1 9
            |> map (i: nameValuePair "${command}_${toString i}" "${prefix} - ${toString i}")
            |> builtins.listToAttrs;
        in
          {
            window_focus_west = "${super} - h";
            window_focus_east = "${super} - l";
            window_focus_north = "${super} - k";
            window_focus_south = "${super} - j";
            window_swap_west = "${super} + shift - h";
            window_swap_east = "${super} + shift - l";
            window_swap_north = "${super} + shift - k";
            window_swap_south = "${super} + shift - j";
            window_center = "${super} - m";
            window_resize = "${super} - r";
            window_fullwidth = "${super} - f";
            window_manage = "${super} - v";
            window_stack = "${super} - period";
            window_unstack = "${super} - comma";
            window_nextdisplay = "${super} - tab";
            window_nextdisplaysend = "${super} + shift - tab";
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
