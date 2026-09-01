{self, ...}: {
  flake.modules.nixos.immich = {config, ...}: let
    inherit (config.homelab) dataDir;
    inherit (config.services.immich) user;
  in {
    users.users.${user}.extraGroups = ["video" "render"];
    services.immich = {
      enable = true;
      accelerationDevices = null;
      host = self.hosts.${config.networking.hostName}.tailscaleIP;
      inherit (self.services.immich) port;
      mediaLocation = "${dataDir}/immich";
    };
  };
}
