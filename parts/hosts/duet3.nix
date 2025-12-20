{inputs, ...}: let
  inherit (import ./_helpers.nix inputs) mkMobile;
  hostname = "duet3";
in {
  flake.nixosConfigurations."${hostname}" = mkMobile {
    inherit hostname;
    username = "sam";
    device = "lenovo-wormdingler";
    sshPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHK6sBwLbi0FkwXzzZO7Mbd6ha66KX+zSOJgGUWiTYzL duet3";
    nixosModules = with inputs.self.modules.nixos; [
      plasma
      ({pkgs, ...}: {
        hardware.firmware = [pkgs.chromeos-sc7180-unredistributable-firmware];
        hardware.sensor.iio.enable = false;
        swapDevices = [
          {
            device = "/swapfile";
            size = 4 * 1024;
          }
        ];
      })
    ];
    homeModules = with inputs.self.modules.homeManager; [
      plasma
      vscode
    ];
  };
}
