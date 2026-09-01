{self, ...}: {
  flake.modules.nixos.vaultwarden = {config, ...}: let
    inherit (config.homelab) domain email dataDir;
    inherit (email) from host user;
    inherit (self.services.vaultwarden) port subdomain;
  in {
    sops.secrets."vaultwarden.env".owner = "vaultwarden";
    services.vaultwarden = {
      enable = true;
      backupDir = "${dataDir}/vaultwarden/backup";
      environmentFile = config.sops.secrets."vaultwarden.env".path;
      config = {
        DOMAIN = "https://${subdomain}.${domain}";
        SIGNUPS_ALLOWED = false;
        INVITATIONS_ALLOWED = true;
        IP_HEADER = "X-Forwarded-For";
        ROCKET_ADDRESS = self.hosts.${config.networking.hostName}.tailscaleIP;
        ROCKET_PORT = port;
        SMTP_HOST = host;
        SMTP_FROM = from;
        SMTP_USERNAME = user;
        SMTP_PORT = 587;
        SMTP_SECURITY = "starttls";
      };
    };
  };
}
