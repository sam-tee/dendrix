{self, ...}: {
  flake.modules.nixos.tandoor = {config, ...}: let
    inherit (config.homelab) domain group user;
    inherit (self.services.tandoor) port subdomain;
  in {
    sops.secrets.tandoorPwd = {};
    services.tandoor-recipes = {
      enable = true;
      inherit group user port;
      extraConfig = {
        TZ = "Europe/London";
        ALLOWED_HOSTS = "${subdomain}.${domain}";
        POSTGRES_PASSWORD = config.sops.secrets.tandoorPwd.path;
        START_SSH_SERVER = true;
      };
    };
  };
}
