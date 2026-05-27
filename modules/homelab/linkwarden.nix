{self, ...}: {
  flake.modules.nixos.linkwarden = {config, ...}: let
    inherit (config.homelab) dataDir group;
  in {
    sops.secrets.linkwardenEnv = {};
    services.linkwarden = {
      enable = true;
      inherit group;
      inherit (self.services.linkwarden) port;
      host = "0.0.0.0";
      storageLocation = "${dataDir}/linkwarden";
      environmentFile = config.sops.secrets.linkwardenEnv.path;
    };
  };
}
