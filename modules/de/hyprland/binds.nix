{
  flake.modules.homeManager.hyprland = _: {
    wayland.windowManager.hyprland.settings = {
      "$noctalia" = "noctalia msg";
      "$mod" = "SUPER";
      "$terminal" = "ghostty";
      "$fileManager" = "ghostty -e yazi";
      "$browser" = "brave --new-window --ozone-platform=wayland";
      gesture = [
        "3, horizontal, workspace"
        "3, vertical, dispatcher, exec, $noctalia launcher toggle"
      ];
      bind = let
        fn = i:
          toString (i + 1)
          |> (ws: [
            "$mod, ${ws}, workspace, ${ws}"
            "$mod SHIFT, ${ws}, movetoworkspace, ${ws}"
          ]);
        binds = 9 |> builtins.genList fn |> builtins.concatLists;
      in
        binds
        ++ [
          "$mod, Q, killactive,"
          "$mod, V, togglefloating,"
          "$mod, F, fullscreen,"

          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"
          "$mod SHIFT, left, movewindow, l"
          "$mod SHIFT, right, movewindow, r"
          "$mod SHIFT, up, movewindow, u"
          "$mod SHIFT, down, movewindow, d"
          "$mod SHIFT ALT, left, swapwindow, l"
          "$mod SHIFT ALT, right, swapwindow, r"
          "$mod SHIFT ALT, up, swapwindow, u"
          "$mod SHIFT ALT, down, swapwindow, d"
          "$mod, minus, resizeactive, -100 0"
          "$mod, equal, resizeactive, 100 0"
          "$mod SHIFT, minus, resizeactive, 0 -100"
          "$mod SHIFT, equal, resizeactive, 0 100"

          "$mod SHIFT, S, exec, hyprshot -m region"
          "$mod, return, exec, $terminal"
          "$mod, B, exec, $browser"
          "$mod, E, exec, $fileManager"
          "$mod, Z, exec, zeditor"
          "$mod SHIFT, ESCAPE, exit,"
          "$mod, space, exec, $noctalia panel-toggle launcher"
          "$mod, S, exec, $noctalia panel-toggle control-center"
          "$mod, comma, exec, $noctalia settings toggle"
        ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
        "$mod ALT, mouse:272, resizewindow"
      ];
      bindel = [
        ",XF86AudioRaiseVolume, exec, $noctalia volume-up"
        ",XF86AudioLowerVolume, exec, $noctalia volume-doun"
        ",XF86AudioMute, exec, $noctalia volume-mute"
        ",XF86AudioMicMute, exec, $noctalia mic-mute"
        ",XF86MonBrightnessUp, exec, $noctalia brightness-up"
        ",XF86MonBrightnessDown, exec, $noctalia brightness-down"
      ];
    };
  };
}
