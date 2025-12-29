{
  flake.modules.nixos.cockpit = {config, ...}: {
    services = {
      cloudflared.tunnels.${config.cloudflared.tunnel}.ingress."dash.akhlus.uk" = "http://localhost:9090";
      cockpit = {
        enable = true;
        openFirewall = true;
      };
    };
  };
}
