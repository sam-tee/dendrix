{self, ...}: {
  flake.modules.nixos.audiobookshelf = {config, ...}: {
    services.audiobookshelf = {
      enable = true;
      inherit (self.services.audiobookshelf) port;
      inherit (config.homelab) group user;
      dataDir = "audiobooks";
    };
  };
}
