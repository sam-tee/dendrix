{
  flake.modules.nixos.immich = {config, ...}: {
    services = {
      cloudflared.tunnels.${config.cloudflared.tunnel}.ingress."photos.akhlus.uk" = "http://localhost:2283";
      immich = {
        enable = true;
        openFirewall = true;
        group = "media";
        mediaLocation = "/var/lib/media/photos";
      };
    };
  };
}
