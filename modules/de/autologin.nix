{
  flake.modules.nixos.autologin = {config, ...}: {
    services.displayManager.autoLogin = {
      enable = true;
      user = config.username;
    };
  };
}
