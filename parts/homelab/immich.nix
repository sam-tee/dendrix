{
  flake.modules.nixos.immich = {config, ...}: let
    inherit (config.homelab) group user;
  in {
    homelab.ingress.photos = "2283";
    users.users.${user}.extraGroups = ["video" "render"];
    services.immich = {
      enable = true;
      openFirewall = true;
      accelerationDevices = null;
      host = "0.0.0.0";
      inherit group;
      mediaLocation = "/var/lib/media/immich";
    };
  };
}
