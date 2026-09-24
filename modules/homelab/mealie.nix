{self, ...}: {
  flake.modules.nixos.mealie = {config, ...}: let
    inherit (config.homelab) caddyIP dataDir email machineIP;
    inherit (email) host user from;
    inherit (self.services.mealie) fqdn port;
  in {
    sops.secrets."mealieEnv" = {};
    systemd.services.mealie.environment.HOME = "${dataDir}/mealie";
    services.mealie = {
      enable = true;
      inherit port;
      credentialsFile = config.sops.secrets.mealieEnv.path;
      listenAddress = machineIP;
      settings = {
        BASE_URL = "https://${fqdn}";
        FORWARDED_ALLOW_IPS = caddyIP;
        SMTP_HOST = host;
        SMTP_PORT = 587;
        SMTP_FROM_NAME = "Mealie";
        SMTP_FROM_EMAIL = from;
        SMTP_AUTH_STRATEGY = "TLS";
        SMTP_USER = user;
        ALLOW_SIGNUP = "false";
      };
    };
  };
}
