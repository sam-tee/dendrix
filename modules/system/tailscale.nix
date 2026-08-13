{self, ...}: {
  flake.modules = {
    nixos.default = self.modules.nixos.tailscale;
    nixos.tailscale = {config, ...}: let
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
    darwin.default = self.modules.darwin.tailscale;
    darwin.tailscale = _: {
      services.tailscale.enable = true;
    };
  };
}
