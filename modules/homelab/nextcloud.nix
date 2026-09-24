{
  flake.modules.nixos.nextcloud = {config, ...}: let
    inherit (config.homelab) dataDir domain;
    hostname = config.networking.hostName;
  in {
    sops.secrets."nextcloud/adminPwd" = {};
    services.nextcloud = {
      enable = true;
      home = "${dataDir}/docs";
      inherit hostname;
      database.createLocally = true;
      configureRedis = true;
      maxUploadSize = "16G";
      https = true;
      settings.trusted_domains = [hostname "localhost" domain];
      config = {
        dbtype = "pgsql";
        adminuser = "admin";
        adminpassFile = config.sops.secrets."nextcloud/adminPwd".path;
      };
    };
  };
}
