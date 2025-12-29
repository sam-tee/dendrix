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
      tunnels."74f00e3d-6f30-493c-b088-ae42a415ba23" = {
        default = "http_status:404";
        credentialsFile = config.sops.secrets."cloudflared/credentials.json".path;
      };
    };
  };
}
