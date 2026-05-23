{self, ...}: {
  flake.modules.nixos.calibre = {config, ...}: let
    inherit (config.homelab) group user dataDir;
  in {
    services.calibre-web = {
      enable = true;
      dataDir = "${dataDir}/calibre-web";
      inherit group user;
      listen = {
        ip = "0.0.0.0";
        inherit (self.services.calibre) port;
      };
      openFirewall = true;
      options = {
        calibreLibrary = "${dataDir}/books";
        enableBookConversion = true;
        enableBookUploading = true;
      };
    };
  };
}
