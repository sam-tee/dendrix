{
  flake.modules.nixos.calibre = {config, ...}: let
    cfg = config.homelab;
  in {
    services.calibre-web = {
      enable = true;
      dataDir = "/var/lib/media/calibre-web";
      inherit (cfg) group user;
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
