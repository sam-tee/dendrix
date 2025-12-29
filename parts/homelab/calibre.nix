{
  flake.modules.nixos.calibre = let
    group = "media";
    libDir = "/var/lib/media/Calibre";
  in {
    services = {
      calibre-server = {
        enable = true;
        inherit group;
        libraries = [libDir];
        openFirewall = true;
      };
      calibre-web = {
        enable = true;
        dataDir = "/var/lib/media/calibre-web";
        inherit group;
        openFirewall = true;
        options = {
          calibreLibrary = libDir;
          enableBookConversion = true;
          enableBookUploading = true;
        };
      };
    };
  };
}
