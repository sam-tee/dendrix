{self, ...}: {
  flake.modules = {
    nixos = {
      default = self.modules.nixos.tailscale;
      tailscale = {
        config,
        lib,
        pkgs,
        ...
      }: let
        cfg = config.services.tailscale;
        inherit (lib) mkIf mkTsIp;
        ip = config.homelab.machineIP or (mkTsIp config.networking.hostName);
      in {
        networking.firewall = {
          trustedInterfaces = [cfg.interfaceName];
          allowedUDPPorts = [cfg.port];
        };
        services.tailscale = {
          enable = true;
          permitCertUid = config.homelab.user or null;
        };
        systemd.services = {
          tailscaled.serviceConfig.Environment = [
            "TS_DEBUG_FIREWALL_MODE=nftables"
          ];
          tailscale-ip = mkIf (ip != "0.0.0.0") {
            description = "Wait for the tailscale IP ${ip} to be assigned";
            after = ["tailscaled.service"];
            wants = ["tailscaled.service"];
            path = with pkgs; [iproute2 gnugrep];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
              TimeoutStartSec = "2min";
            };
            script = ''
              until ip -4 -o addr show dev ${cfg.interfaceName} | grep -qF "inet ${ip}/"; do
                sleep 0.5
              done
            '';
          };
        };
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
