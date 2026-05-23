{self, ...}: {
  flake.modules.nixos.atuin = _: {
    services.atuin = {
      enable = true;
      openFirewall = true;
      inherit (self.services.atuin) port;
      openRegistration = false;
      maxHistoryLength = 1024 * 16;
    };
  };
}
