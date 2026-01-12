{
  flake.modules.nixos.vaultwarden = {config, ...}: let
    cfg = config.homelab.email;
  in {
    sops.secrets."vaultwarden.env".owner = "vaultwarden";
    services.vaultwarden = {
      enable = true;
      backupDir = "/var/lib/media/vaultwarden/backup";
      environmentFile = config.sops.secrets."vaultwarden.env".path;
      config = {
        DOMAIN = "https://vault.akhlus.uk";
        SIGNUPS_ALLOWED = false;
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
        SMTP_HOST = cfg.host;
        SMTP_FROM = cfg.from;
        SMTP_USERNAME = cfg.user;
        SMTP_PORT = 587;
        SMTP_SECURITY = "starttls";
      };
    };
  };
}
