{self, ...}: {
  flake.modules.nixos.calibre = {config, ...}: let
    inherit (config.homelab) group user dataDir;
  in {
    services.calibre-web = {
      enable = true;
      inherit group user;
      dataDir = "${dataDir}/calibre-web";
      listen = {
        ip = self.hosts.${config.networking.hostName}.tailscaleIP;
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
