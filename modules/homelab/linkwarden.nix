{self, ...}: {
  flake.modules.nixos.linkwarden = {config, ...}: let
    inherit (config.homelab) dataDir group;
  in {
    sops.secrets.linkwardenEnv = {};
    services.linkwarden = {
      enable = true;
      inherit group;
      inherit (self.services.linkwarden) port;
      host = self.hosts.${config.networking.hostName}.tailscaleIP;
      storageLocation = "${dataDir}/linkwarden";
      cacheLocation = "${dataDir}/linkwarden/cache";
      environmentFile = config.sops.secrets.linkwardenEnv.path;
    };
  };
}
