{
  lib,
  self,
  ...
}: let
  hostname = "duet3";
in {
  flake = {
    hosts.${hostname} = {
      username = "sam";
      system = "lenovo-wormdingler";
      hostType = "nixos";
      pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL6mOpHficE7rnvg6pNw6SwSU39O2riglK511CGh5p+V";
      syncID = "WEFNJAE-V6VFYEI-J4KAORY-IYHRJBR-MVUK7XV-C3UPGDY-BSL3ZJL-HIOROAD";
      tailscaleIP = "100.100.10.14";
    };

    nixosConfigurations = self.lib.mkMobile hostname;

    modules.nixos.${hostname} = {pkgs, ...}: {
      imports = with self.modules.nixos; [
        gdm
        gui
        hyprland
        hyprTouch
      ];
      hardware.firmware = [pkgs.chromeos-sc7180-unredistributable-firmware];
      hjem.extraModules = lib.singleton {
        xdg.config.files."hypr/hyprland.lua".text = lib.mkAfter ''
          hl.monitor({output="DSI-1", mode="1200x2000@60", scale=1.5, transform=1})
          hl.device({name="hid-over-i2c-0603:604a",output="DSI-1"})
          hl.device({name="hid-over-i2c-0603:604a-stylus",output="DSI-1"})
          hl.config({
            input={
              tablet = {output="DSI-1", transform=1,},
              touchdevice = {output="DSI-1", transform=1,},
            },
          })
          hl.on("hyprland.start", function()
            hl.exec_cmd("iio-hyprland DSI-1 --transform 0,1,2,3")
          end)
        '';
      };
      services.displayManager.noctalia-greeter.enable = false;
    };
  };
}
