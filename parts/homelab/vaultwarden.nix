{
  flake.modules.nixos.vaultwarden = {config, ...}: {
    services = {
      cloudflared.tunnels.${config.cloudflared.tunnel}.ingress."vault.akhlus.uk" = "http://localhost:8222";
      vaultwarden = {
        enable = true;
        backupDir = "/var/lib/media/vaultwarden/backup";
        config = {
          DOMAIN = "https://vault.akhlus.uk";
          SIGNUPS_ALLOWED = false;
          ROCKET_ADDRESS = "127.0.0.1";
          ROCKET_PORT = 8222;
        };
      };
    };
  };
}
