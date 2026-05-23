{
  flake.modules.nixos.autologin = {username, ...}: {
    services.displayManager.autoLogin = {
      enable = true;
      user = username;
    };
  };
}
