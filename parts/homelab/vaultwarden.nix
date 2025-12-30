{
  flake.modules.nixos.vaultwarden = {config, ...}: {
    sops.secrets."vaultwarden.env" = {};
    services = {
      vaultwarden = {
        enable = true;
        backupDir = "/var/lib/media/vaultwarden/backup";
        environmentFile = [config.sops.secrets."vaultwarden.env".path];
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
