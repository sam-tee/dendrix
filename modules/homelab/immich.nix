{self, ...}: {
  flake.modules.nixos.immich = {config, ...}: let
    inherit (config.homelab) dataDir machineIP;
    inherit (config.services.immich) user;
  in {
    users.users.${user}.extraGroups = ["video" "render"];
    services.immich = {
      enable = true;
      accelerationDevices = null;
      host = machineIP;
      inherit (self.services.immich) port;
      mediaLocation = "${dataDir}/immich";
    };
  };
}
