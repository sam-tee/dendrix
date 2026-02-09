{
  flake.modules.nixos.immich = {config, ...}: let
    inherit (config.homelab) domain group user;
  in {
    homelab.ingress.photos = "2283";
    users.users.${user}.extraGroups = ["video" "render"];
    services = {
      caddy.virtualHosts."upload.${domain}" = {
        useACMEHost = domain;
        extraConfig = ''
          reverse_proxy http://127.0.0.1:2283
        '';
      };
      immich = {
        enable = true;
        openFirewall = true;
        accelerationDevices = null;
        host = "0.0.0.0";
        inherit group;
        mediaLocation = "/var/lib/media/immich";
      };
    };
  };
}
