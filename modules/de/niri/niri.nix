{inputs, ...}: {
  flake-file.inputs.niri-flake = {
    url = "github:sodiboo/niri-flake";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules = {
    nixos.niri = {pkgs, ...}: {
      imports = with inputs.self.modules.nixos; [
        inputs.niri-flake.nixosModules.niri
        wm
      ];
      hjem.extraModules = [inputs.self.modules.hjem.niri];
      programs.niri = {
        enable = true;
        package = pkgs.niri;
      };
    };
    hjem.niri = _: let
      wsBind = n: "Mod+${toString n} { action focus-workspace ${toString n} }";
      wsMove = n: "Mod+Shift+${toString n} { action move-window-to-workspace ${toString n} }";
      numberedBinds =
        9
        |> builtins.genList (i: let
          n = i + 1;
        in "${wsBind n}\n${wsMove n}")
        |> builtins.concatStringsSep "\n";
    in {
      xdg.config.files."niri/config.kdl".text = ''
        spawn-at-startup "noctalia"
        spawn-at-startup "bitwarden"
        spawn-at-startup "xwayland-satellite"

        input {
            keyboard { xkb { layout "gb" options "caps:escape" } }
            touchpad { natural-scroll true }
            focus-follows-mouse { enable true }
            warp-mouse-to-focus { enable true }
        }
        layout {
            gaps 0
            preset-column-widths { proportion 0.5 }
            default-column-width { proportion 0.5 }
            border { enable true width 1 }
            focus-ring { enable false }
        }
        animations { enable false }
        gestures { hot-corners { enable false } }

        binds {
            Mod+H { action focus-column-left }
            Mod+L { action focus-column-right }
            Mod+K { action focus-window-up }
            Mod+J { action focus-window-down }
            Mod+Shift+H { action move-column-left }
            Mod+Shift+L { action move-column-right }
            Mod+Shift+K { action move-window-up }
            Mod+Shift+J { action move-window-down }
            Mod+M { action center-column }
            Mod+R { action switch-preset-column-width }
            Mod+F { action maximize-column }
            Mod+V { action toggle-window-floating }
            Mod+Period { action consume-window-into-column }
            Mod+Comma { action expel-window-from-column }

            Mod+Q { action close-window }
            Mod+Shift+F { action fullscreen-window }

            Mod+Left { action focus-column-left }
            Mod+Right { action focus-column-right }
            Mod+Up { action focus-window-up }
            Mod+Down { action focus-window-down }
            Mod+Shift+Left { action move-column-left }
            Mod+Shift+Right { action move-column-right }
            Mod+Shift+Up { action move-window-up }
            Mod+Shift+Down { action move-window-down }
            Mod+Minus { action set-column-width "-10%" }
            Mod+Equal { action set-column-width "+10%" }
            Mod+Shift+Minus { action set-window-height "-10%" }
            Mod+Shift+Equal { action set-window-height "+10%" }
            Mod+Shift+Ctrl+Left { action move-column-to-monitor-left }
            Mod+Shift+Ctrl+Right { action move-column-to-monitor-right }
            Mod+Shift+Ctrl+Up { action move-window-to-monitor-up }
            Mod+Shift+Ctrl+Down { action move-window-to-monitor-down }
            Mod+Shift+S { action spawn "noctalia" "msg" "screenshot-region" }
            Mod+Shift+V { action spawn "noctalia" "msg" "panel-toggle" "clipboard" }
            Mod+Return { action spawn "ghostty" }
            Mod+B { action spawn "brave" "--new-window" "--ozone-platform=wayland" }
            Mod+E { action spawn "ghostty" "-e" "yazi" }
            Mod+Z { action spawn "zeditor" }
            Mod+Shift+Escape { action quit }
            Mod+Space { action spawn "noctalia" "msg" "panel-toggle" "launcher" }
            Mod+S { action spawn "noctalia" "msg" "panel-toggle" "control-center" }
            Mod+Shift+Comma { action spawn "noctalia" "msg" "settings-toggle" }

            XF86AudioRaiseVolume { action spawn "noctalia" "msg" "volume-up" }
            XF86AudioLowerVolume { action spawn "noctalia" "msg" "volume-down" }
            XF86AudioMute { action spawn "noctalia" "msg" "volume-mute" }
            XF86AudioMicMute { action spawn "noctalia" "msg" "mic-mute" }
            XF86MonBrightnessUp { action spawn "noctalia" "msg" "brightness-up" }
            XF86MonBrightnessDown { action spawn "noctalia" "msg" "brightness-down" }

            ${numberedBinds}
        }

        window-rule {
            matches [ title="Picture.*(in)?.*[Pp]icture" ]
            open-floating true
        }
        window-rule {
            matches [ app-id="gamescope" ]
            open-floating true
            open-fullscreen true
        }
      '';
    };
  };
}
