{
  flake.modules.nixos.audiobookshelf = {config, ...}: {
    services = {
      cloudflared.tunnels.${config.cloudflared.tunnel}.ingress."audiobook.akhlus.uk" = "http://localhost:8000";
      audiobookshelf = {
        enable = true;
        openFirewall = true;
        group = "media";
        dataDir = "media/audiobooks";
      };
    };
  };
}
