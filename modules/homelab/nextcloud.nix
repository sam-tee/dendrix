{
  flake.modules.nixos.nextcloud = {config, ...}: let
    inherit (config.homelab) dataDir;
  in {
    sops.secrets."nextcloud/adminPwd" = {};
    services.nextcloud = {
      enable = true;
      home = "${dataDir}/docs";
      hostName = "u410";
      database.createLocally = true;
      configureRedis = true;
      maxUploadSize = "16G";
      https = true;
      settings.trusted_domains = ["u410" "localhost" "192.168.10.0/24" "u410.scylla-goblin.ts.net"];
      config = {
        dbtype = "pgsql";
        adminuser = "admin";
        adminpassFile = config.sops.secrets."nextcloud/adminPwd".path;
      };
    };
  };
}
