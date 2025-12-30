{
  flake.modules.nixos.homelab = {
    config,
    pkgs,
    ...
  }: {
    sops.secrets = {
      "cloudflared/cert.pem" = {};
      "cloudflared/credentials.json" = {};
    };
    environment.systemPackages = [pkgs.cloudflared];
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
