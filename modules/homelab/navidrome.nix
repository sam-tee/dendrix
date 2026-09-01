{self, ...}: {
  flake.modules.nixos.navidrome = {config, ...}: let
    inherit (config.homelab) group user dataDir;
  in {
    services.navidrome = {
      enable = true;
      inherit group user;
      settings = {
        Port = self.services.navidrome.port;
        Address = self.hosts.${config.networking.hostName}.tailscaleIP;
        MusicFolder = "${dataDir}/media/music";
        DataFolder = "${dataDir}/navidrome";
      };
    };
  };
}
