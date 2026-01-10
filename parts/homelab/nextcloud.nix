{
  flake.modules.nixos.nextcloud = {
    config,
    pkgs,
    ...
  }: {
    sops.secrets."nextcloud/adminPwd" = {};
    services.nextcloud = {
      enable = true;
      home = "/var/lib/media/docs";
      hostName = "u410";
      database.createLocally = true;
      package = pkgs.nextcloud32;
      configureRedis = true;
      maxUploadSize = "16G";
      https = true;
      settings.trusted_domains = ["*.akhlus.uk" "192.168.10.0/24" "*.scylla-goblin.ts.net"];
      config = {
        dbtype = "sqlite";
        adminuser = "admin";
        adminpassFile = config.sops.secrets."nextcloud/adminPwd".path;
      };
    };
  };
}
