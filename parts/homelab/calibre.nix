{
  flake.modules.nixos.calibre = {config, ...}: let
    group = "media";
    libDir = "/var/lib/media/Calibre";
  in {
    services = {
      cloudflared.tunnels.${config.cloudflared.tunnel}.ingress = {
        "calibre-server.akhlus.uk" = "http://localhost:8080";
        "calibre.akhlus.uk" = "http://localhost:8083";
      };
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
