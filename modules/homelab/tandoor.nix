{
  flake.modules.nixos.tandoor = {config, ...}: let
    inherit (config.homelab) domain group user;
  in {
    homelab.ingress.cooking = "8765";
    sops.secrets.tandoorPwd = {};
    services.tandoor-recipes = {
      enable = true;
      inherit group user;
      port = 8765;
      extraConfig = {
        TZ = "Europe/London";
        ALLOWED_HOSTS = "cooking.${domain}";
        POSTGRES_PASSWORD = config.sops.secrets.tandoorPwd;
      };
    };
  };
}
