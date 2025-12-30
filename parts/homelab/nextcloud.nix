{
  flake.modules.nixos.nextcloud = {
    config,
    pkgs,
    ...
  }: {
    sops.secrets."nextcloud/adminPassword" = {};
    services = {
      nextcloud = {
        enable = true;
        home = "/var/lib/media/docs";
        hostName = "cloud.akhlus.uk";
        database.createLocally = true;
        package = pkgs.nextcloud32;
        configureRedis = true;
        https = true;
        settings.trusted_domains = ["*.akhlus.uk" "192.168.10.0/24" "*.scylla-goblin.ts.net"];
        config = {
          dbtype = "sqlite";
          adminuser = "admin";
          adminpassFile = config.sops.secrets."nextcloud/adminPassword".path;
        };
      };
    };
  };
}
