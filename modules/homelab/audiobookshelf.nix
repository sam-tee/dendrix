{self, ...}: {
  flake.modules.nixos.audiobookshelf = {config, ...}: {
    services.audiobookshelf = {
      enable = true;
      inherit (self.services.audiobookshelf) port;
      inherit (config.homelab) group user;
      host = "0.0.0.0";
      dataDir = "audiobooks";
    };
  };
}
