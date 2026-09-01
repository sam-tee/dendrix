{self, ...}: {
  flake.modules.nixos.slskd = {config, ...}: let
    inherit (config.homelab) group user dataDir;
    mkIP = host: self.hosts.${host}.tailscaleIP;
  in {
    sops.secrets.slskd = {};
    services.slskd = {
      inherit user group;
      enable = true;
      environmentFile = config.sops.secrets.slskd.path;
      settings = {
        web = {
          port = self.services.slskd.port;
          ip_address = mkIP config.networking.hostName;
        };
        directories = {
          downloads = "${dataDir}/slskd/downloads";
          incomplete = "${dataDir}/slskd/incomplete";
        };
      };
    };
  };
}
