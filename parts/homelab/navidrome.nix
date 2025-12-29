{
  flake.modules.nixos.navidrome = {config, ...}: {
    services = {
      cloudflared.tunnels.${config.cloudflared.tunnel}.ingress."music.akhlus.uk" = "http://localhost:4533";
      navidrome = {
        enable = true;
        openFirewall = true;
        group = "media";
        settings = {
          MusicFolder = "/var/lib/media/music";
          DataFolder = "/var/lib/media/navidrome";
        };
      };
    };
  };
}
