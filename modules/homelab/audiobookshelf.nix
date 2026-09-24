{self, ...}: {
  flake.modules.nixos.audiobookshelf = {config, ...}: let
    inherit (config.homelab) group machineIP user;
  in {
    services.audiobookshelf = {
      enable = true;
      inherit (self.services.audiobookshelf) port;
      inherit group user;
      host = machineIP;
      dataDir = "audiobooks";
    };
  };
}
