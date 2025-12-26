{
  flake.modules.nixos.homelab = {config, ...}: {
    sops.secrets."cloudflared" = {
      owner = "cloudflared";
      group = "cloudflared";
    };
    services.cloudflared = {
      enable = true;
      certificateFile = config.sops.secrets."cloudflared/cert".path;
      tunnels = {
        "test" = {
          credentialsFile = config.sops.secrets."cloudflared/test".path;
        };
      };
    };
  };
}
