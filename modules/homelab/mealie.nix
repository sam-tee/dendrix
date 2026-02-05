{
  flake.modules.nixos.mealie = {config, ...}: {
    sops.secrets."mealieEnv" = {};
    homelab.ingress.mealie = "9876";
    services.mealie = {
      enable = true;
      port = 9876;
      credentialsFile = config.sops.secrets.mealieEnv.path;
      settings = {
        ALLOW_SIGNUP = "false";
      };
    };
  };
}
