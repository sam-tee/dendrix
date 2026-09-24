{self, ...}: {
  flake.modules.nixos.linkwarden = {config, ...}: let
    inherit (config.homelab) dataDir group machineIP;
  in {
    sops.secrets.linkwardenEnv = {};
    services.linkwarden = {
      enable = true;
      inherit group;
      inherit (self.services.linkwarden) port;
      host = machineIP;
      storageLocation = "${dataDir}/linkwarden";
      cacheLocation = "${dataDir}/linkwarden/cache";
      environmentFile = config.sops.secrets.linkwardenEnv.path;
    };
  };
}
