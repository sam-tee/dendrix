{self, ...}: {
  flake.modules.nixos.navidrome = {config, ...}: let
    inherit (config.homelab) group user dataDir;
  in {
    services.navidrome = {
      enable = true;
      openFirewall = true;
      inherit group user;
      settings = {
        Port = self.services.navidrome.port;
        MusicFolder = "${dataDir}/media/music";
        DataFolder = "${dataDir}/navidrome";
      };
    };
  };
}
