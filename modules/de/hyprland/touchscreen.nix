{
  lib,
  moduleWithSystem,
  self,
  ...
}: let
  inherit (lib) mkAfter singleton;
in {
  flake.modules = let
    hyprgrass = pkgs: (pkgs.callPackage ./_hyprgrass.nix {});
  in {
    nixos.hyprTouch = moduleWithSystem ({inputs', ...}: {pkgs, ...}: {
      # noctalia greeter has no osk so use gdm for login instead
      imports = with self.modules.nixos; [
        gdm
        hyprland
      ];
      services.displayManager.noctalia-greeter.enable = false;
      hardware.sensor.iio.enable = true;
      environment.systemPackages = [
        pkgs.wvkbd
        inputs'.iio-hyprland.packages.default
        (hyprgrass pkgs)
      ];
      hjem.extraModules = singleton self.modules.hjem.hyprTouch;
    });
    hjem.hyprTouch = {pkgs, ...}: {
      # noctalia's lockscreen has no osk: show wvkbd while locked (merged with config.toml)
      xdg.config.files."noctalia/hyprtouch.toml" = {
        generator = (pkgs.formats.toml {}).generate "hyprtouch.toml";
        value.hooks = {
          session_locked = ["${pkgs.procps}/bin/pkill -USR2 -x wvkbd-mobintl"];
          session_unlocked = ["${pkgs.procps}/bin/pkill -USR1 -x wvkbd-mobintl"];
        };
      };
      xdg.config.files."hypr/hyprland.lua".text = mkAfter ''
        -- render wvkbd above the session lock and let it take touch input
        hl.layer_rule({
          name = "wvkbd-above-lock",
          match = {namespace = "^wvkbd$"},
          above_lock = 2,
        })

        hl.on("hyprland.start", function()
          hl.exec_cmd("wvkbd-mobintl")
          hl.exec_cmd("hyprctl plugin load ${hyprgrass pkgs}/lib/libhyprgrass.so")
          hl.exec_cmd("${pkgs.iio-hyprland}/bin/iio-hyprland DSI-1 --transform 1,2,3,0")
        end)

        hl.config({
          plugin = {
            hyprgrass = {
              sensitivity = 3.0,
              resize_on_border_long_press = true,
            },
          },
        })

        hl.plugin.hyprgrass.gesture({
          pattern = {kind = "swipe", fingers = 3, direction = "horizontal"},
          action = "workspace",
        })

        hl.plugin.hyprgrass.bind({
          pattern = {kind = "edge", origin = "down", direction = "up"},
          action = hl.dsp.exec_cmd("kill -34 $(ps -C wvkbd-mobintl)"),
        })
        hl.plugin.hyprgrass.bind({
          pattern = {kind = "edge", origin = "top", direction = "down"},
          action = hl.dsp.exec_cmd(noct .. " panel-toggle launcher"),
        })
        hl.plugin.hyprgrass.gesture({
          pattern = {kind = "swipe", fingers = 3, direction = "up"},
          action = "fullscreen"
        })
        hl.plugin.hyprgrass.bind({
          pattern = {kind = "swipe", fingers = 4, direction = "down"},
          action = hl.dsp.window.close(),
        })
      '';
    };
  };
}
