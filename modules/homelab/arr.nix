{
  flake.modules.nixos.arr = {config, ...}: let
    inherit (config.homelab) group user;
    mkConf = service: {
      enable = true;
      inherit group user;
      dataDir = "/var/lib/media/${service}";
    };
  in {
    services = {
      bazarr = mkConf "bazarr";
      jellyseerr.enable = true;
      #lidarr = mkConf "lidarr";
      #prowlarr.enable = true;
      #radarr = mkConf "radarr";
      #sonarr = mkConf "sonarr";
      #qbittorrent = {
      #  enable = true;
      #  inherit group user;
      #};
    };
  };
}
