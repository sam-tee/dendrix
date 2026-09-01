{self, ...}: {
  flake.modules.nixos.navidrome = {config, ...}: let
    inherit (config.homelab) group user dataDir;
    mkIP = host: self.hosts.${host}.tailscaleIP;
  in {
    services.navidrome = {
      enable = true;
      inherit group user;
      settings = {
        Port = self.services.navidrome.port;
        Address = self.hosts.${config.networking.hostName}.tailscaleIP;
        MusicFolder = "${dataDir}/media/music";
        DataFolder = "${dataDir}/navidrome";
        ReverseProxyUserHeader = "X-Forwarded-User";
        ReverseProxyWhitelist = "${mkIP "oracle"}/32,127.0.0.1/32,::1/128";
      };
    };
  };
}
