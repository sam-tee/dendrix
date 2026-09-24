{self, ...}: {
  flake.modules.nixos.navidrome = {config, ...}: let
    inherit (config.homelab) caddyIP group user dataDir machineIP;
  in {
    services.navidrome = {
      enable = true;
      inherit group user;
      settings = {
        Port = self.services.navidrome.port;
        Address = machineIP;
        MusicFolder = "${dataDir}/media/music";
        DataFolder = "${dataDir}/navidrome";
        ReverseProxyUserHeader = "X-Forwarded-User";
        ReverseProxyWhitelist = "${caddyIP}/32,127.0.0.1/32,::1/128";
      };
    };
  };
}
