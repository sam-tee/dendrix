{self, ...}: {
  flake.modules.nixos.jellyfin = {config, ...}: let
    inherit (config.homelab) group user dataDir;
  in {
    services.jellyfin = {
      enable = true;
      inherit group user;
      dataDir = "${dataDir}/jellyfin";
      cacheDir = "${dataDir}/jellyfin/cache";
    };
    systemd.services.jellyfin.environment.KNOWN_PROXIES =
      self.hosts.oracle.tailscaleIP;
  };
}
