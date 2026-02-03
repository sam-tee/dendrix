{
  flake.modules.homeManager.hyprland = _: {
    wayland.windowManager.hyprland.settings = {
      bind =
        (builtins.concatLists (builtins.genList (
            i: [
              "$mod, code:1${toString i}, workspace, ${toString (i + 1)}"
              "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString (i + 1)}"
            ]
          )
          9))
        ++ [
          "$mod, space, exec, wofi --show drun --sort-order=alphabetical"
          "$mod SHIFT, SPACE, exec, pkill -SIGUSR1 waybar"
          "$mod, Q, killactive,"

          "$mod, ESCAPE, exec, hyprlock"
          "$mod SHIFT, ESCAPE, exit,"
          "$mod CTRL, ESCAPE, exec, reboot"
          "$mod SHIFT CTRL, ESCAPE, exec, systemctl poweroff"

          "$mod, J, togglesplit, # dwindle"
          "$mod, P, pseudo, # dwindle"
          "$mod, V, togglefloating,"
          "$mod SHIFT, Plus, fullscreen,"

          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"
          "$mod SHIFT, left, swapwindow, l"
          "$mod SHIFT, right, swapwindow, r"
          "$mod SHIFT, up, swapwindow, u"
          "$mod SHIFT, down, swapwindow, d"
          "$mod, minus, resizeactive, -100 0"
          "$mod, equal, resizeactive, 100 0"
          "$mod SHIFT, minus, resizeactive, 0 -100"
          "$mod SHIFT, equal, resizeactive, 0 100"

          "$mod, S, togglespecialworkspace, magic"
          "$mod SHIFT, S, movetoworkspace, special:magic"

          ", PRINT, exec, hyprshot -m region"
          "SHIFT, PRINT, exec, hyprshot -m window"
          "CTRL, PRINT, exec, hyprshot -m output"

          "$mod, PRINT, exec, hyprpicker -a"
          "CTRL $mod, V, exec, ghostty --class clipse -e clipse"
        ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
        "$mod ALT, mouse:272, resizewindow"
      ];
      bindel = [
        ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
        ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
      ];
    };
  };
}
