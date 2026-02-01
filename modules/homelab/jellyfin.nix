{
  flake.modules.nixos.jellyfin = {config, ...}: let
    inherit (config.homelab) domain group user;
  in {
    services = {
      caddy.virtualHosts."media.${domain}" = {
        useACMEHost = domain;
        extraConfig = ''
          reverse_proxy http://127.0.0.1:8096
        '';
      };
      jellyfin = {
        enable = true;
        openFirewall = true;
        inherit group user;
        dataDir = "/var/lib/media/jellyfin";
        cacheDir = "/var/lib/media/jellyfin/cache";
      };
    };
  };
}
