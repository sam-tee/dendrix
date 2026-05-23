{self, ...}: {
  flake.modules.nixos.slskd = {config, ...}: let
    inherit (config.homelab) group user dataDir;
  in {
    sops.secrets.slskd = {};
    services.slskd = {
      inherit user group;
      enable = true;
      environmentFile = config.sops.secrets.slskd.path;
      settings = {
        web.port = self.services.slskd.port;
        directories = {
          downloads = "${dataDir}/slskd/downloads";
          incomplete = "${dataDir}/slskd/incomplete";
        };
      };
    };
  };
}
