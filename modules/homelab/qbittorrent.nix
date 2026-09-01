{self, ...}: {
  flake.modules.nixos.qbittorrent = {config, ...}: let
    inherit (config.homelab) group user;
    mkIP = host: self.hosts.${host}.tailscaleIP;
  in {
    services.qbittorrent = {
      enable = true;
      inherit group user;
      webuiPort = self.services.qbittorrent.port;
      serverConfig.Preferences.WebUI = {
        Address = mkIP config.networking.hostName;
        ReverseProxySupportEnabled = true;
        TrustedReverseProxiesList = mkIP "oracle";
      };
    };
  };
}
