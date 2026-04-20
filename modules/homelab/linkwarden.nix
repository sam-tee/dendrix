{
  flake.modules.nixos.linkwarden = {config, ...}: let
    inherit (config.homelab) dataDir user group;
  in {
    sops.secrets.linkwardenEnv = {};
    homelab.ingress.link = "9183";
    services.linkwarden = {
      enable = true;
      inherit group user;
      port = 9183;
      storageLocation = "${dataDir}/linkwarden";
      enableRegistration = true;
      environmentFile = config.sops.secrets.linkwardenEnv.path;
    };
  };
}
