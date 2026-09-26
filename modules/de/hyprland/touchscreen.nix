{
  lib,
  moduleWithSystem,
  self,
  ...
}: {
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
      hjem.extraModules = lib.singleton self.modules.hjem.hyprTouch;
    });
    hjem.hyprTouch = {pkgs, ...}: {
      xdg.config.files."hypr/hyprland.lua".text = lib.mkAfter ''
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
