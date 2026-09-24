{self, ...}: {
  flake.modules.nixos.home-assistant = {config, ...}: let
    inherit (config.homelab) caddyIP machineIP;
    inherit (self.services.home-assistant) fqdn port;
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
          server_host = machineIP;
          inherit port;
          use_x_forwarded_for = true;
          trusted_proxies = [machineIP caddyIP];
        };
        homeassistant = {
          name = "Home";
          external_url = "https://${fqdn}";
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
