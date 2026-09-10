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
        hostname = config.networking.hostName;
        expected = self.hosts.${hostname}.tailscaleIP or "0.0.0.0";
        checker = pkgs.writeShellApplication {
          name = "tailscale-ip-check";
          runtimeInputs = with pkgs; [tailscale coreutils systemd];
          text = ''
            set -euo pipefail

            expected=${lib.escapeShellArg expected}
            host=${lib.escapeShellArg hostname}

            # Bind-all mode needs no pin: skip the check.
            if [ "$expected" = "0.0.0.0" ] || [ -z "$expected" ]; then
              echo "tailscale-ip-check: $host pins '$expected' (bind-all), skipping drift check."
              exit 0
            fi

            # Wait up to 60s for tailscaled to report an IPv4.
            actual=""
            for _ in $(seq 1 30); do
              actual="$(tailscale ip -4 2>/dev/null | tr -d '[:space:]' || true)"
              case "$actual" in
                100.*) break ;;
              esac
              sleep 2
            done

            if [ "$actual" = "$expected" ]; then
              echo "tailscale-ip-check: $host Tailscale IPv4 $actual matches repo pin."
              exit 0
            fi

            {
              echo "ERROR: Tailscale IPv4 drift detected on host '$host'."
              echo "  expected (repo pin modules/hosts/$host.nix tailscaleIP): $expected"
              if [ -n "$actual" ]; then
                echo "  actual (tailscale ip -4): $actual"
              else
                echo "  actual (tailscale ip -4): <none — tailscaled not reporting an IPv4>"
              fi
              echo "  Services binding the stale IP will fail with:"
              echo "    EADDRNOTAVAIL / errno 99 'Cannot assign requested address'"
              echo "  Fix: set tailscaleIP to '$actual' in modules/hosts/$host.nix, then:"
              echo "    sudo nixos-rebuild switch --flake ~/dendrix#$host"
            } >&2
            exit 1
          '';
        };
      in {
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
        systemd.services.tailscale-ip-check = {
          description = "Fail if Tailscale IPv4 drifted from repo pin";
          wantedBy = ["multi-user.target"];
          after = ["tailscaled.service" "network-online.target"];
          wants = ["tailscaled.service"];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = lib.getExe checker;
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
