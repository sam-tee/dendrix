{
  flake.modules.nixos.jellyfin = {config, ...}: let
    inherit (config.homelab) group user;
  in {
    homelab.ingress.media = "8096";
    services.jellyfin = {
      enable = true;
      openFirewall = true;
      inherit group user;
      dataDir = "/var/lib/media/jellyfin";
      cacheDir = "/var/lib/media/jellyfin/cache";
    };
  };
}
