{
  flake.modules.nixos.arr = {config, ...}: let
    cfg = config.homelab;
    user = cfg.user;
    group = cfg.group;
    mkConf = service: {
      enable = true;
      inherit group user;
      dataDir = "/var/lib/media/${service}";
    };
  in {
    services = {
      services = {
        bazarr = mkConf "bazarr";
        jellyseerr.enable = true;
        lidarr = mkConf "lidarr";
        prowlarr.enable = true;
        radarr = mkConf "radarr";
        sonarr = mkConf "sonarr";
        qbittorrent = {
          enable = true;
          inherit group user;
        };
      };
    };
  };
}
