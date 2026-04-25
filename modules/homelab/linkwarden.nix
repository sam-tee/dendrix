{
  flake.modules.nixos.linkwarden = {config, ...}: let
    inherit (config.homelab) dataDir group;
  in {
    sops.secrets.linkwardenEnv = {};
    homelab.ingress.link = "9183";
    services.linkwarden = {
      enable = true;
      inherit group;
      port = 9183;
      storageLocation = "${dataDir}/linkwarden";
      environmentFile = config.sops.secrets.linkwardenEnv.path;
    };
  };
}
