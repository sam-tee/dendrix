{self, ...}: {
  flake.modules.nixos.calibre = {config, ...}: let
    inherit (config.homelab) group machineIP user dataDir;
  in {
    services.calibre-web = {
      enable = true;
      inherit group user;
      dataDir = "${dataDir}/calibre-web";
      listen = {
        ip = machineIP;
        inherit (self.services.calibre) port;
      };
      options = {
        calibreLibrary = "${dataDir}/books";
        enableBookConversion = true;
        enableBookUploading = true;
      };
    };
  };
}
