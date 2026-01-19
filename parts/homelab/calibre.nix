{
  flake.modules.nixos.calibre = {config, ...}: let
    inherit (config.homelab) group user;
  in {
    homelab.ingress.books = "8083";
    services.calibre-web = {
      enable = true;
      dataDir = "/var/lib/media/calibre-web";
      inherit group user;
      listen.ip = "0.0.0.0";
      openFirewall = true;
      options = {
        calibreLibrary = "/var/lib/media/books";
        enableBookConversion = true;
        enableBookUploading = true;
      };
    };
  };
}
