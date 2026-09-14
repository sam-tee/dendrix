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
      syncID = "LVSIHL6-LFUENR2-KX22SIV-TMVCDWF-3RSQAZJ-ACD5DHB-ATHYI2E-GW63LAQ";
      tailscaleIP = "100.100.10.14";
    };

    nixosConfigurations = self.lib.mkMobile hostname;

    modules.nixos.${hostname} = {pkgs, ...}: {
      imports = with self.modules.nixos; [
        autologin
        hyprland
        hyprTouch
      ];
      hardware.firmware = [pkgs.chromeos-sc7180-unredistributable-firmware];
      hardware.sensor.iio.enable = true;
      swapDevices = lib.singleton {
        device = "/swapfile";
        size = 4 * 1024;
      };
    };
  };
}
