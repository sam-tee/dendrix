{self, ...}: {
  flake.modules.nixos.cliproxyapi = {config, ...}: let
    inherit (self.services.cliproxyapi) port;
  in {
    services.cliproxyapi = {
      enable = true;
      settings = {
        server = {
          host = config.homelab.machineIP;
          inherit port;
        };
        access.api-keys = [{_secret = config.sops.secrets.cliproxyapi-key.path;}];
        management = {
          allow-remote = true;
          secret-key._secret = config.sops.secrets.cliproxyapi-key.path;
        };
        routing = {
          cooldown.disable-cooling = true;
          strategy = "round-robin";
          session-affinity = true;
          session-affinity-ttl = "1h";
          retry = {
            request-retry = 3;
            max-retry-interval = 30;
          };
        };
        requests.passthrough-headers = true;
      };
    };
    systemd.services.cliproxyapi = {
      after = ["tailscaled.service"];
      wants = ["tailscaled.service"];
    };
  };
}
