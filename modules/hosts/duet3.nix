{self, ...}: let
  hostname = "duet3";
in {
  flake = {
    hosts.${hostname} = {
      username = "sam";
      system = "lenovo-wormdingler";
      pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL6mOpHficE7rnvg6pNw6SwSU39O2riglK511CGh5p+V";
      syncID = "LVSIHL6-LFUENR2-KX22SIV-TMVCDWF-3RSQAZJ-ACD5DHB-ATHYI2E-GW63LAQ";
    };

    nixosConfigurations = self.lib.mkMobile hostname;

    modules.nixos.duet3Config = {pkgs, ...}: {
      imports = with self.modules.nixos; [
        _mobile
        hm
        autologin
        hyprland
      ];
      home-manager.sharedModules = with self.modules.homeManager; [
        _linuxMinimal
        hyprTouch
        syncthing
        {
          wayland.windowManager.hyprland.settings = {
            monitor = ["DSI-1,1200x2000@60,0x0,1,transform,1"];
            device = [
              {
                name = "hid-over-i2c-0603:604a";
                output = "DSI-1";
                transform = 1;
              }
              {
                name = "hid-over-i2c-0603:604a-stylus";
                output = "DSI-1";
                transform = 1;
              }
              {
                name = "google-inc.-hammer-1";
                output = "DSI-1";
                transform = 1;
              }
            ];
          };
        }
      ];
      hardware.firmware = [pkgs.chromeos-sc7180-unredistributable-firmware];
      hardware.sensor.iio.enable = true;
      swapDevices = [
        {
          device = "/swapfile";
          size = 4 * 1024;
        }
      ];
    };
  };
}
