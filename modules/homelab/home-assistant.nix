{self, ...}: {
  flake.modules.nixos.home-assistant = _: {
    services.home-assistant = {
      enable = true;
      extraComponents = [
        "tado"
        "cast"
        "google_wifi"
      ];
      config = {
        http = {
          server_host = "0.0.0.0";
          server_port = self.services.home-assistant.port;
          use_x_forwarded_for = true;
          trusted_proxies = ["100.75.222.43"];
        };
        homeassistant = {
          name = "Home";
          external_url = "https://ha.ts.akhlus.uk";
        };
      };
    };
  };
}
