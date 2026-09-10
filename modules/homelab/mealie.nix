{self, ...}: {
  flake.modules.nixos.mealie = {config, ...}: let
    inherit (config.homelab) dataDir email;
    inherit (email) host user from;
    inherit (self.services.mealie) port subdomain;
    mkIP = host: self.hosts.${host}.tailscaleIP;
  in {
    sops.secrets."mealieEnv" = {};
    systemd.services.mealie.environment.HOME = "${dataDir}/mealie";
    services.mealie = {
      enable = true;
      inherit port;
      credentialsFile = config.sops.secrets.mealieEnv.path;
      listenAddress = mkIP config.networking.hostName;
      settings = {
        BASE_URL = "https://${subdomain}.${config.homelab.domain}";
        FORWARDED_ALLOW_IPS = mkIP "oracle";
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
