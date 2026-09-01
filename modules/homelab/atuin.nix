{self, ...}: {
  flake.modules.nixos.atuin = {config, ...}: {
    services.atuin = {
      enable = true;
      host = self.hosts.${config.networking.hostName}.tailscaleIP;
      inherit (self.services.atuin) port;
      openRegistration = false;
      maxHistoryLength = 1024 * 128;
    };
    systemd.services.atuin.environment.ATUIN_TRUSTED_PROXIES =
      self.hosts.oracle.tailscaleIP;
  };
}
