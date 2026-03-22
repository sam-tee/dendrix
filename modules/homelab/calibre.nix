{
  flake.modules.nixos.calibre = {config, ...}: let
    inherit (config.homelab) group user dataDir;
  in {
    homelab.ingress.books = "8083";
    services.calibre-web = {
      enable = true;
      dataDir = "${dataDir}/calibre-web";
      inherit group user;
      listen.ip = "0.0.0.0";
      openFirewall = true;
      options = {
        calibreLibrary = "${dataDir}/books";
        enableBookConversion = true;
        enableBookUploading = true;
      };
    };
  };
}
