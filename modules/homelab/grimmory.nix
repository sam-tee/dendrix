{self, ...}: {
  flake.modules.nixos.grimmory = {config, ...}: let
    inherit (config.homelab) dataDir group user;
    inherit (self.services.grimmory) port;
  in {
    sops.secrets."grimmoryDbPwd" = {};
    services.grimmory = {
      enable = true;
      inherit group port user;
      dataDir = "${dataDir}/grimmory";
      diskType = "NETWORK";
      databasePasswordFile = config.sops.secrets."grimmoryDbPwd".path;
    };
  };
}
