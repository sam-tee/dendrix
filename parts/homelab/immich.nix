{
  flake.modules.nixos.immich = {config, ...}: let
    cfg = config.homelab;
  in {
    users.users.${cfg.user}.extraGroups = ["video" "render"];
    services.immich = {
      enable = true;
      openFirewall = true;
      accelerationDevices = null;
      host = "0.0.0.0";
      inherit (cfg) group;
      mediaLocation = "/var/lib/media/immich";
    };
  };
}
