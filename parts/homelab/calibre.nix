{
  flake.modules.nixos.calibre = {username, ...}: let
    group = "media";
    user = username;
    libDir = "/var/lib/media/calibre";
    host = "127.0.0.1";
  in {
    services = {
      calibre-web = {
        enable = true;
        dataDir = "/var/lib/media/calibre-web";
        inherit group user;
        listen.ip = host;
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
