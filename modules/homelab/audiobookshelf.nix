{self, ...}: {
  flake.modules.nixos.audiobookshelf = {config, ...}: {
    services.audiobookshelf = {
      enable = true;
      openFirewall = true;
      inherit (self.services.audiobookshelf) port;
      inherit (config.homelab) group user;
      dataDir = "drive/media/audiobooks";
    };
  };
}
