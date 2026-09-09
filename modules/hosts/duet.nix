{self, ...}: let
  hostname = "duet";
in {
  flake = {
    hosts.${hostname} = {
      username = "sam";
      system = "lenovo-krane";
      hostType = "nixos";
      pubKey = "";
      syncID = "";
    };

    nixosConfigurations = self.lib.mkMobile hostname;

    modules.nixos.${hostname} = {lib, ...}: {
      imports = with self.modules.nixos; [
        autologin
        gdm
        gnome
      ];
      swapDevices = lib.singleton {
        device = "/swapfile";
        size = 4 * 1024;
      };
    };
  };
}
