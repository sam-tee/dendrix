{
  lib,
  self,
  ...
}: {
  flake.modules = let
    hyprgrass = pkgs: (pkgs.callPackage ./_hyprgrass.nix {});
  in {
    nixos.hyprTouch = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.wvkbd
        (hyprgrass pkgs)
      ];
      hjem.extraModules = lib.singleton self.modules.hjem.hyprTouch;
    };
    hjem.hyprTouch = {pkgs, ...}: {
      xdg.config.files."hypr/hyprland.lua".text = lib.mkAfter ''
        hl.on("hyprland.start", function()
          hl.exec_cmd("wvkbd-mobintl")
          hl.exec_cmd("hyprctl plugin load ${hyprgrass pkgs}/lib/libhyprgrass.so")
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
          pattern = {kind = "tap", fingers = 3},
          action = hl.dsp.exec_cmd(noct .. " launcher toggle"),
        })
        hl.plugin.hyprgrass.bind({
          pattern = {kind = "swipe", fingers = 4, direction = "down"},
          action = hl.dsp.window.close(),
        })
      '';
    };
  };
}
