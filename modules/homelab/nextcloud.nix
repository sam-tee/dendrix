{
  flake.modules.nixos.nextcloud = {
    config,
    pkgs,
    ...
  }: let
    inherit (config.homelab) domain dataDir;
  in {
    sops.secrets."nextcloud/adminPwd" = {};
    services = {
      caddy.virtualHosts."cloud.${domain}" = {
        useACMEHost = config.homelab.domain;
        extraConfig = ''
          reverse_proxy http://127.0.0.1:8009
        '';
      };
      nextcloud = {
        enable = true;
        home = "${dataDir}/docs";
        hostName = "u410";
        database.createLocally = true;
        package = pkgs.nextcloud33;
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
  };
}
