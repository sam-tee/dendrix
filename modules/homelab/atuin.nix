{self, ...}: {
  flake.modules.nixos.atuin = {config, ...}: let
    inherit (config.homelab) caddyIP machineIP;
  in {
    services.atuin = {
      enable = true;
      host = machineIP;
      inherit (self.services.atuin) port;
      openRegistration = false;
      maxHistoryLength = 1024 * 128;
    };
    systemd.services.atuin.environment.ATUIN_TRUSTED_PROXIES = caddyIP;
  };
}
