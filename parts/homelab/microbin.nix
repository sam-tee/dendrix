{
  flake.modules.nixos.microbin = {config, ...}: {
    sops.secrets."microbin.env" = {};
    services = {
      cloudflared.tunnels.${config.cloudflared.tunnel}.ingress."bin.akhlus.uk" = "http://localhost:8069";
      microbin = {
        enable = true;
        dataDir = "/var/lib/media/microbin";
        passwordFile = config.sops.secrets."microbin.env".path;
        settings = {
          MICROBIN_PORT = 8069;
          MICROBIN_HIDE_LOGO = true;
          MICROBIN_HIGHLIGHTSYNTAX = true;
          MICROBIN_HIDE_HEADER = true;
          MICROBIN_HIDE_FOOTER = true;
        };
      };
    };
  };
}
