{
  flake.modules.nixos.linkwarden = {config, ...}: let
    inherit (config.homelab) dataDir;
  in {
    sops.secrets.linkwardenEnv = {};
    homelab.ingress.link = "9183";
    services.linkwarden = {
      enable = true;
      port = 9183;
      storageLocation = "${dataDir}/linkwarden";
      environmentFile = config.sops.secrets.linkwardenEnv.path;
    };
  };
}
