{self, ...}: {
  flake.modules.nixos.atticd = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (self.services.atticd) fqdn port;
    inherit (lib) singleton;
    inherit (config.homelab) dataDir machineIP;
    atticDir = "${dataDir}/attic";
  in {
    sops.secrets."atticd-env" = {};
    services = {
      atticd = {
        enable = true;
        environmentFile = config.sops.secrets."atticd-env".path;
        settings = {
          listen = "${machineIP}:${toString port}";
          api-endpoint = "https://${fqdn}/";
          storage = {
            type = "local";
            path = "${atticDir}/storage";
          };
          database.url = "postgres://atticd@localhost/atticd?host=/run/postgresql";
          chunking = {
            nar-size-threshold = 64 * 1024;
            min-size = 16 * 1024;
            avg-size = 64 * 1024;
            max-size = 256 * 1024;
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
      services.atticd = {
        serviceConfig.ReadWritePaths = singleton atticDir;
        waitForTailscaleIP = true;
      };
      tmpfiles.rules = singleton "d ${atticDir} 0775 atticd atticd -";
    };
    environment.systemPackages = singleton pkgs.attic-client;
  };
}
