{inputs, ...}: {
  flake-file.inputs.niri-flake = {
    url = "github:sodiboo/niri-flake";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules = {
    nixos.niri = {pkgs, ...}: {
      imports = with inputs.self.modules.nixos; [
        inputs.niri-flake.nixosModules.niri
        sddm
        wm
      ];
      home-manager.sharedModules = with inputs.self.modules.homeManager; [
        niri
      ];
      programs.niri = {
        enable = true;
        package = pkgs.niri;
      };
    };
    homeManager.niri = {
      lib,
      pkgs,
      ...
    }: let
      spawn = command: {action.spawn = command;};
      action = name: {action.${name} = [];};
      focusWorkspace = workspace: {action.focus-workspace = workspace;};
      moveWindowToWorkspace = workspace: {action.move-window-to-workspace = workspace;};
    in {
      programs.niri = {
        package = pkgs.niri;
        settings = {
          spawn-at-startup = [
            {argv = ["noctalia"];}
            {argv = ["bitwarden"];}
            {argv = ["xwayland-satellite"];}
          ];

          input = {
            keyboard.xkb = {
              layout = "gb";
              options = "caps:escape";
            };
            touchpad.natural-scroll = true;
            focus-follows-mouse.enable = true;
            warp-mouse-to-focus.enable = true;
          };

          layout = {
            gaps = 0;
            preset-column-widths = [{proportion = 0.5;}];
            default-column-width.proportion = 0.5;
            border = {
              enable = true;
              width = 1;
            };
            focus-ring.enable = false;
          };

          animations.enable = false;

          binds =
            {
              "Mod+H" = action "focus-column-left";
              "Mod+L" = action "focus-column-right";
              "Mod+K" = action "focus-window-up";
              "Mod+J" = action "focus-window-down";
              "Mod+Shift+H" = action "move-column-left";
              "Mod+Shift+L" = action "move-column-right";
              "Mod+Shift+K" = action "move-window-up";
              "Mod+Shift+J" = action "move-window-down";
              "Mod+M" = action "center-column";
              "Mod+R" = action "switch-preset-column-width";
              "Mod+F" = action "maximize-column";
              "Mod+V" = action "toggle-window-floating";
              "Mod+Period" = action "consume-window-into-column";
              "Mod+Comma" = action "expel-window-from-column";

              "Mod+Q" = action "close-window";
              "Mod+Shift+F" = action "fullscreen-window";

              "Mod+Left" = action "focus-column-left";
              "Mod+Right" = action "focus-column-right";
              "Mod+Up" = action "focus-window-up";
              "Mod+Down" = action "focus-window-down";
              "Mod+Shift+Left" = action "move-column-left";
              "Mod+Shift+Right" = action "move-column-right";
              "Mod+Shift+Up" = action "move-window-up";
              "Mod+Shift+Down" = action "move-window-down";
              "Mod+Minus".action.set-column-width = "-10%";
              "Mod+Equal".action.set-column-width = "+10%";
              "Mod+Shift+Minus".action.set-window-height = "-10%";
              "Mod+Shift+Equal".action.set-window-height = "+10%";

              "Mod+Shift+S" = spawn ["hyprshot" "-m" "region"];
              "Mod+Return" = spawn "ghostty";
              "Mod+B" = spawn ["brave" "--new-window" "--ozone-platform=wayland"];
              "Mod+E" = spawn ["ghostty" "-e" "yazi"];
              "Mod+Z" = spawn "zeditor";
              "Mod+Shift+Escape" = action "quit";
              "Mod+Space" = spawn ["noctalia" "ipc" "call" "launcher" "toggle"];
              "Mod+S" = spawn ["noctalia" "ipc" "call" "controlCenter" "toggle"];
              "Mod+Shift+Comma" = spawn ["noctalia" "ipc" "call" "settings" "toggle"];

              "XF86AudioRaiseVolume" = spawn ["noctalia" "ipc" "call" "volume" "increase"];
              "XF86AudioLowerVolume" = spawn ["noctalia" "ipc" "call" "volume" "decrease"];
              "XF86AudioMute" = spawn ["noctalia" "ipc" "call" "volume" "muteOutput"];
              "XF86AudioMicMute" = spawn ["noctalia" "ipc" "call" "volume" "muteInput"];
              "XF86MonBrightnessUp" = spawn ["noctalia" "ipc" "call" "brightness" "increase"];
              "XF86MonBrightnessDown" = spawn ["noctalia" "ipc" "call" "brightness" "decrease"];
            }
            // (
              lib.range 1 9
              |> map (i: let
                ws = toString i;
              in {
                "Mod+${ws}" = focusWorkspace i;
                "Mod+Shift+${ws}" = moveWindowToWorkspace i;
              })
              |> lib.mergeAttrsList
            );

          window-rules = [
            {
              matches = [{title = "Picture.*(in)?.*[Pp]icture";}];
              open-floating = true;
            }
            {
              matches = [{app-id = "gamescope";}];
              open-floating = true;
              open-fullscreen = true;
            }
          ];
        };
      };
    };
  };
}
