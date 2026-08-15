{
  lib,
  self,
  ...
}: let
  inherit (self.cosmetic.theme) attrs defaultVariant;
  inherit (attrs.${defaultVariant}) base03;
  noHashBase03 = lib.removePrefix "#" base03;
in {
  flake.modules = {
    nixos.hyprland = {pkgs, ...}: {
      imports = [self.modules.nixos.wm];
      hjem.extraModules = [self.modules.hjem.hyprland];
      programs.hyprland = {
        enable = true;
        withUWSM = true;
        xwayland.enable = true;
      };
      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-termfilechooser
          xdg-desktop-portal-gtk
        ];
        config.common."org.freedesktop.impl.portal.FileChooser" = ["termfilechooser"];
      };
    };
    hjem.hyprland = {pkgs, ...}: {
      xdg.config.files = {
        "xdg-desktop-portal-termfilechooser/config".text = ''
          [filechooser]
          cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
          default_dir=$HOME
          env=TERMCMD=ghostty --title="terminal-filechooser" -e
          open_mode=suggested
          save_mode=last
        '';
        "hypr/hyprland.lua".text = ''
          local Mod = "SUPER"
          local noct = "noctalia msg"
          local term = "ghostty"
          local files = "ghostty -e yazi"
          local browser = "helium --new-window --ozone-platform=wayland"

          hl.on("hyprland.start", function()
            hl.exec_cmd("noctalia")
            hl.exec_cmd("bitwarden")
          end)

          hl.config({
            cursor = {no_hardware_cursors = true,},
            general = {
              border_size = 1,
              gaps_in = 0,
              gaps_out = 0,
              col = {
                active_border = "rgb(${noHashBase03})",
                inactive_border = "rgb(${noHashBase03})",
              },
            },
            animations = {enabled = false,},
            misc = {
              disable_hyprland_logo = true,
              disable_splash_rendering = true,
            },
            input = {
              kb_layout = "gb",
              kb_options = "caps:escape",
              touchpad = {natural_scroll = true,},
            },
          })

          for i = 1, 9 do
            hl.workspace_rule({ workspace = tostring(i), persistent = true })
          end

          hl.window_rule({
            name = "browser-pip",
            match = { title = "^(Picture-in-[Pp]icture)$" },
            float = true,
            pin = true,
            size = "368 207",
            move = "(monitor_w-window_w) (monitor_h-window_h)",
          })
          hl.window_rule({
            name = "fullscreen inhibit idle",
            match = { class = ".*" },
            idle_inhibit = "fullscreen",
          })
          hl.window_rule({
            name = "gamescope",
            match = { class = "^(gamescope)$" },
            fullscreen = true,
            float = true,
          })

          hl.bind(Mod .. " + Q", hl.dsp.window.close())
          hl.bind(Mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
          hl.bind(Mod .. " + F", hl.dsp.window.fullscreen())
          hl.bind(Mod .. " + left", hl.dsp.focus({ direction = "left" }))
          hl.bind(Mod .. " + right", hl.dsp.focus({ direction = "right" }))
          hl.bind(Mod .. " + up", hl.dsp.focus({ direction = "up" }))
          hl.bind(Mod .. " + down", hl.dsp.focus({ direction = "down" }))
          hl.bind(Mod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
          hl.bind(Mod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
          hl.bind(Mod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
          hl.bind(Mod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))
          hl.bind(Mod .. " + SHIFT + ALT + left", hl.dsp.window.swap({ direction = "left" }))
          hl.bind(Mod .. " + SHIFT + ALT + right", hl.dsp.window.swap({ direction = "right" }))
          hl.bind(Mod .. " + SHIFT + ALT + up", hl.dsp.window.swap({ direction = "up" }))
          hl.bind(Mod .. " + SHIFT + ALT + down", hl.dsp.window.swap({ direction = "down" }))
          hl.bind(Mod .. " + minus", hl.dsp.window.resize({ x = -100, y = 0 }))
          hl.bind(Mod .. " + equal", hl.dsp.window.resize({ x = 100, y = 0 }))
          hl.bind(Mod .. " + SHIFT + minus", hl.dsp.window.resize({ x = 0, y = -100 }))
          hl.bind(Mod .. " + SHIFT + equal", hl.dsp.window.resize({ x = 0, y = 100 }))
          for i = 1, 9 do
            hl.bind(Mod .. " + " .. i, hl.dsp.focus({ workspace = i }))
            hl.bind(Mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
          end
          hl.bind(Mod .. " + return", hl.dsp.exec_cmd(term))
          hl.bind(Mod .. " + B", hl.dsp.exec_cmd(browser))
          hl.bind(Mod .. " + E", hl.dsp.exec_cmd(files))
          hl.bind(Mod .. " + Z", hl.dsp.exec_cmd("zeditor"))
          hl.bind(Mod .. " + SHIFT + ESCAPE", hl.dsp.exit())
          hl.bind(Mod .. " + SHIFT + S", hl.dsp.exec_cmd(noct .. " screenshot-region"))
          hl.bind(Mod .. " + SHIFT + V", hl.dsp.exec_cmd(noct .. " panel-toggle clipboard"))
          hl.bind(Mod .. " + space", hl.dsp.exec_cmd(noct .. " panel-toggle launcher"))
          hl.bind(Mod .. " + S", hl.dsp.exec_cmd(noct .. " panel-toggle control-center"))
          hl.bind(Mod .. " + comma", hl.dsp.exec_cmd(noct .. " settings toggle"))

          hl.bind(Mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
          hl.bind(Mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
          hl.bind(Mod .. " + ALT + mouse:272", hl.dsp.window.resize(), { mouse = true })

          hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(noct .. " volume-up"), { non_consuming = true })
          hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(noct .. " volume-down"), { non_consuming = true })
          hl.bind("XF86AudioMute", hl.dsp.exec_cmd(noct .. " volume-mute"), { non_consuming = true })
          hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(noct .. " mic-mute"), { non_consuming = true })
          hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(noct .. " brightness-up"), { non_consuming = true })
          hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(noct .. " brightness-down"), { non_consuming = true })
        '';
      };
    };
  };
}
