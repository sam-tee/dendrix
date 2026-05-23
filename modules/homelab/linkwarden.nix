{self, ...}: {
  flake.modules.nixos.linkwarden = {config, ...}: let
    inherit (config.homelab) dataDir group;
  in {
    sops.secrets.linkwardenEnv = {};
    services.linkwarden = {
      enable = true;
      inherit group;
      inherit (self.services.linkwarden) port;
      storageLocation = "${dataDir}/linkwarden";
      environmentFile = config.sops.secrets.linkwardenEnv.path;
    };
  };
}
