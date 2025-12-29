{
  flake.modules.nixos.terraria = {config, ...}: {
    services = {
      cloudflared.tunnels.${config.cloudflared.tunnel}.ingress."terraria.akhlus.uk" = "http://localhost:7777";
      terraria = {
        enable = true;
        openFirewall = true;
        dataDir = "/var/lib/media/terraria";
        password = "TerrariaTest123";
      };
    };
  };
}
