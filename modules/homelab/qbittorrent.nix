{self, ...}: {
  flake.modules.nixos.qbittorrent = {config, ...}: let
    inherit (config.homelab) caddyIP group machineIP user;
  in {
    services.qbittorrent = {
      enable = true;
      inherit group user;
      webuiPort = self.services.qbittorrent.port;
      serverConfig.Preferences.WebUI = {
        Address = machineIP;
        ReverseProxySupportEnabled = true;
        TrustedReverseProxiesList = caddyIP;
      };
    };
  };
}
