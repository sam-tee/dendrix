{
  flake.modules.nixos.vaultwarden = {config, ...}: let
    inherit (config.homelab.email) from host user;
  in {
    homelab.ingress.vault = "8222";
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
        SMTP_HOST = host;
        SMTP_FROM = from;
        SMTP_USERNAME = user;
        SMTP_PORT = 587;
        SMTP_SECURITY = "starttls";
      };
    };
  };
}
