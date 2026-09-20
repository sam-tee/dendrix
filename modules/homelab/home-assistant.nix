{self, ...}: {
  flake.modules.nixos.home-assistant = {config, ...}: let
    mkIP = host: self.hosts.${host}.tailscaleIP;
    hostIP = mkIP config.networking.hostName;
  in {
    services.home-assistant = {
      enable = true;
      extraComponents = [
        "tado"
        "cast"
        "google_wifi"
      ];
      config = {
        http = {
          server_host = hostIP;
          server_port = self.services.home-assistant.port;
          use_x_forwarded_for = true;
          trusted_proxies = [hostIP (mkIP "oracle")];
        };
        homeassistant = {
          name = "Home";
          external_url = "https://ha.ts.akhlus.uk";
        };
        sensor = [
          {
            platform = "google_wifi";
            host = "192.168.86.1";
          }
        ];
      };
    };
  };
}
