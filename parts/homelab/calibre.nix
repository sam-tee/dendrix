{
  flake.modules.nixos.calibre = {
    services.calibre-web = {
      enable = true;
      dataDir = "/var/lib/media/calibre-web";
      group = "media";
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
