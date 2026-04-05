{self, ...}: let
  hostname = "duet";
in {
  flake = {
    hosts.${hostname} = {
      username = "sam";
      system = "lenovo-krane";
      pubKey = "";
      syncID = "";
    };

    nixosConfigurations = self.lib.mkMobile hostname;

    modules.nixos.duetConfig = {lib, ...}: {
      imports = with self.modules.nixos; [
        _mobile
        hm
        autologin
        gnomeHM
      ];
      home-manager.sharedModules = with self.modules.homeManager; [
        _linuxMinimal
        syncthing
      ];
      swapDevices = lib.singleton {
        device = "/swapfile";
        size = 4 * 1024;
      };
    };
  };
}
