{self, ...}: {
  flake.modules.nixos.immich = {config, ...}: let
    inherit (config.homelab) group user dataDir;
  in {
    users.users.${user}.extraGroups = ["video" "render"];
    services.immich = {
      enable = true;
      openFirewall = true;
      accelerationDevices = null;
      host = "0.0.0.0";
      inherit group;
      inherit (self.services.immich) port;
      mediaLocation = "${dataDir}/immich";
    };
  };
}
