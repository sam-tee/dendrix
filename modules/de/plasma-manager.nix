{
  flake.modules.nixos.plm = _: {
    services.displayManager.plasma-login-manager.enable = true;
  };
}
