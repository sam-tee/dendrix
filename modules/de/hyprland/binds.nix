{
  flake.modules.homeManager.hyprland = _: {
    wayland.windowManager.hyprland.settings = {
      "$noctalia" = "noctalia-shell ipc call";
      "$mod" = "SUPER";
      "$terminal" = "ghostty";
      "$fileManager" = "dolphin --new-window";
      "$browser" = "brave --new-window --ozone-platform=wayland";
      bind =
        (builtins.concatLists (builtins.genList (
            i: [
              "$mod, code:1${toString i}, workspace, ${toString (i + 1)}"
              "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString (i + 1)}"
            ]
          )
          9))
        ++ [
          "$mod, Q, killactive,"
          "$mod, V, togglefloating,"
          "$mod, F, fullscreen,"

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
          "$mod SHIFT, period, workspace, -1"
          "$mod, period, workspace, +1"

          "$mod SHIFT, S, exec, hyprshot -m region"
          "$mod, return, exec, $terminal"
          "$mod, B, exec, $browser"
          "$mod, E, exec, $fileManager"
          "$mod, ESCAPE, exec, hyprlock"
          "$mod SHIFT, ESCAPE, exit,"
          "$mod, space, exec, $noctalia launcher toggle"
          "$mod, S, exec, $noctalia controlCenter toggle"
          "$mod, comma, exec, $noctalia settings toggle"
        ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
        "$mod ALT, mouse:272, resizewindow"
      ];
      bindel = [
        ",XF86AudioRaiseVolume, exec, $noctalia volume increase"
        ",XF86AudioLowerVolume, exec, $noctalia volume decrease"
        ",XF86AudioMute, exec, $noctalia volume muteOutput"
        ",XF86AudioMicMute, exec, $noctalia volume muteInput"
        ",XF86MonBrightnessUp, exec, $noctalia brightness increase"
        ",XF86MonBrightnessDown, exec, $noctalia brightness decrease"
      ];
    };
  };
}
