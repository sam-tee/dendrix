{
  flake.modules.nixos.jellyfin = {config, ...}: let
    cfg = config.homelab;
  in {
    services.jellyfin = {
      enable = true;
      openFirewall = true;
      inherit (cfg) group user;
      dataDir = "/var/lib/media/jellyfin";
      cacheDir = "/var/lib/media/jellyfin/cache";
    };
  };
}
