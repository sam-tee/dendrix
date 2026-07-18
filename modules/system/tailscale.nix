{
  flake.modules = {
    nixos.networking = {config, ...}: let
      cfg = config.services.tailscale;
    in {
      sops.secrets."tailscale/authKey" = {};
      networking.firewall = {
        trustedInterfaces = [cfg.interfaceName];
        allowedUDPPorts = [cfg.port];
      };
      services.tailscale = {
        enable = true;
        authKeyFile = config.sops.secrets."tailscale/authKey".path;
        permitCertUid = config.homelab.user or null;
      };
      systemd.services.tailscaled.serviceConfig.Environment = [
        "TS_DEBUG_FIREWALL_MODE=nftables"
      ];
    };

    darwin.networking = _: {
      services.tailscale.enable = true;
    };
  };
}
