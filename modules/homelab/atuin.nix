{self, ...}: {
  flake.modules.nixos.atuin = _: {
    services.atuin = {
      enable = true;
      host = "0.0.0.0";
      inherit (self.services.atuin) port;
      openRegistration = false;
      maxHistoryLength = 1024 * 128;
    };
  };
}
