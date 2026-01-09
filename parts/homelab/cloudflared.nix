{
  flake.modules.nixos.homelab = {config, ...}: {
    sops.secrets = {
      "cloudflared/cert.pem" = {};
      "cloudflared/credentials.json" = {};
    };
    services.cloudflared = {
      enable = true;
      certificateFile = config.sops.secrets."cloudflared/cert.pem".path;
      tunnels.${config.homelab.cloudflared.tunnel} = {
        default = "http_status:404";
        credentialsFile = config.sops.secrets."cloudflared/credentials.json".path;
      };
    };
  };
}
