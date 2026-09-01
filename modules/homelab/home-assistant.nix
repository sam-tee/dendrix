{self, ...}: {
  flake.modules.nixos.home-assistant = {config, ...}: let
    mkIP = host: self.hosts.${host}.tailscaleIP;
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
          server_host = mkIP config.networking.hostName;
          server_port = self.services.home-assistant.port;
          use_x_forwarded_for = true;
          trusted_proxies = [(mkIP "oracle")];
        };
        homeassistant = {
          name = "Home";
          external_url = "https://ha.ts.akhlus.uk";
        };
      };
    };
  };
}
