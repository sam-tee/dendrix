{self, ...}: {
  flake.modules = {
    nixos = {
      default = self.modules.nixos.tailscale;
      tailscale = {config, ...}: let
        cfg = config.services.tailscale;
      in {
        sops.secrets."tailscale/authKey" = {};
        networking.firewall = {
          trustedInterfaces = [cfg.interfaceName];
          allowedUDPPorts = [cfg.port];
        };
        services.tailscale = {
          enable = true;
          permitCertUid = config.homelab.user or null;
        };
        systemd.services.tailscaled.serviceConfig.Environment = [
          "TS_DEBUG_FIREWALL_MODE=nftables"
        ];
      };
      server = _: {
        services.tailscale = {
          extraSetFlags = ["--advertise-exit-node"];
          useRoutingFeatures = "server";
        };
      };
    };
    darwin = {
      default = self.modules.darwin.tailscale;
      tailscale = {homebrew.casks = ["tailscale"];};
    };
  };
}
