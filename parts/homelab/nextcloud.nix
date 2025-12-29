{
  flake.modules.nixos.nextcloud = {config, pkgs, ...}: {
    sops.secrets."nextcloud/adminPassword" = {};
    services = {
      cloudflared.tunnels.${config.cloudflared.tunnel}.ingress."cloud.akhlus.uk" = "http://localhost:8009";
      nextcloud = {
        enable = true;
        home = "/var/lib/media/docs";
        hostName = "u410-cloud";
        database.createLocally = true;
        package = pkgs.nextcloud32;
        configureRedis = true;
        https = true;
        config = {
          dbtype = "sqlite";
          adminpassFile = config.sops.secrets."nextcloud/adminPassword".path;
      };};
    };
  };
}
