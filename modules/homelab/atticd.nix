{self, ...}: {
  flake.modules.nixos.atticd = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (config.homelab) dataDir domain;
    inherit (self.services.atticd) port subdomain;
    inherit (lib) singleton;
    atticDir = "${dataDir}/attic";
  in {
    sops.secrets."atticd-env" = {};

    services = {
      atticd = {
        enable = true;
        environmentFile = config.sops.secrets."atticd-env".path;
        settings = {
          listen = "${self.hosts.${config.networking.hostName}.tailscaleIP}:${toString port}";
          api-endpoint = "https://${subdomain}.${domain}/";
          storage = {
            type = "local";
            path = "${atticDir}/storage";
          };
          database.url = "postgres://atticd@localhost/atticd?host=/run/postgresql";
          chunking = {
            nar-size-threshold = 64 * 1024; # 64 KiB
            min-size = 16 * 1024; # 16 KiB
            avg-size = 64 * 1024; # 64 KiB
            max-size = 256 * 1024; # 256 KiB
          };
          garbage-collection.default-retention-period = "3 days";
        };
      };
      postgresql = {
        enable = true;
        ensureDatabases = singleton "atticd";
        ensureUsers = singleton {
          name = "atticd";
          ensureDBOwnership = true;
        };
      };
    };
    systemd = {
      services.atticd.serviceConfig.ReadWritePaths = singleton dataDir;
      tmpfiles.rules = singleton "d ${atticDir} 0775 atticd atticd -";
    };
    environment.systemPackages = singleton pkgs.attic-client;
  };
}
