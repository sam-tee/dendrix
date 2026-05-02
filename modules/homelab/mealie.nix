{
  flake.modules.nixos.mealie = {config, ...}: let
    inherit (config.homelab.email) host user from;
  in {
    sops.secrets."mealieEnv" = {};
    homelab.ingress.mealie = "9876";
    services.mealie = {
      enable = true;
      port = 9876;
      credentialsFile = config.sops.secrets.mealieEnv.path;
      settings = {
        BASE_URL = "https://cooking.${config.homelab.domain}";
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
