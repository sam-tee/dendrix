{self, ...}: {
  flake.modules.nixos.atticd = {
    config,
    pkgs,
    ...
  }: let
    inherit (config.homelab) dataDir domain group user;
    inherit (self.services.atticd) port subdomain;
    atticDir = "${dataDir}/attic";
  in {
    sops.secrets."atticd-env" = {};

    services.atticd = {
      enable = true;
      inherit group user;
      environmentFile = config.sops.secrets."atticd-env".path;
      settings = {
        listen = "0.0.0.0:${toString port}";
        api-endpoint = "https://${subdomain}.${domain}/";
        storage = {
          type = "local";
          path = "${atticDir}/storage";
        };
        database.url = "sqlite://${atticDir}/server.db?mode=rwc";
      };
    };
    systemd = {
      services.atticd.serviceConfig.ReadWritePaths = [dataDir];
      tmpfiles.rules = ["d ${atticDir} 0775 ${user} ${group} -"];
    };
    environment.systemPackages = [pkgs.attic-client];
  };
}
