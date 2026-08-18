{self, ...}: let
  hostname = "duet";
in {
  flake = {
    hosts.${hostname} = {
      username = "sam";
      system = "lenovo-krane";
      hostType = "nixos";
      pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDKLSs9wmp3rSRPnantmeWXdf8G0QNGmNL56Sq0x36FO";
      syncID = "";
    };

    nixosConfigurations = self.lib.mkMobile hostname;

    modules.nixos.${hostname} = {lib, ...}: {
      imports = with self.modules.nixos; [
        autologin
        gnome
      ];
      swapDevices = lib.singleton {
        device = "/swapfile";
        size = 4 * 1024;
      };
    };
  };
}
