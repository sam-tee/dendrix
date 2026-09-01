{self, ...}: {
  flake.modules.nixos.audiobookshelf = {config, ...}: {
    services.audiobookshelf = {
      enable = true;
      inherit (self.services.audiobookshelf) port;
      inherit (config.homelab) group user;
      host = self.hosts.${config.networking.hostName}.tailscaleIP;
      dataDir = "audiobooks";
    };
  };
}
