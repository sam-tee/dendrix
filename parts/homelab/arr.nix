{
  flake.modules.nixos.arr = {config, ...}: let
    cfg = config.homelab;
    mkConf = service: {
      enable = true;
      inherit (cfg) group user;
      dataDir = "/var/lib/media/${service}";
    };
  in {
    services = {
      bazarr = mkConf "bazarr";
      jellyseerr.enable = true;
      lidarr = mkConf "lidarr";
      prowlarr.enable = true;
      radarr = mkConf "radarr";
      sonarr = mkConf "sonarr";
      qbittorrent = {
        enable = true;
        inherit (cfg) group user;
      };
    };
  };
}
