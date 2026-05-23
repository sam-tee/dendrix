{self, ...}: {
  flake.modules.nixos.mealie = {config, ...}: let
    inherit (config.homelab.email) host user from;
    inherit (self.services.mealie) port subdomain;
  in {
    sops.secrets."mealieEnv" = {};
    services.mealie = {
      enable = true;
      inherit port;
      credentialsFile = config.sops.secrets.mealieEnv.path;
      settings = {
        BASE_URL = "https://${subdomain}.${config.homelab.domain}";
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
