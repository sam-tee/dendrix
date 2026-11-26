{self, ...}: {
  flake.modules.nixos = {
    server = {config, ...}: {
      services.prometheus.exporters.node = {
        enable = true;
        listenAddress = config.homelab.machineIP;
        enabledCollectors = ["systemd"];
      };
      systemd.services.prometheus-node-exporter.after = ["tailscaled.service"];
    };

    prometheus = {
      config,
      hostname,
      lib,
      pkgs,
      ...
    }: let
      inherit (lib) filterAttrs mapAttrsToList mkTsIp range;
      inherit (self.services) alertmanager caddy prometheus;
      blackbox = config.services.prometheus.exporters.blackbox;

      exporterHosts =
        self.nixosConfigurations
        |> filterAttrs (_: host: host.config.services.prometheus.exporters.node.enable);

      probedServices =
        self.services
        |> filterAttrs (_: svc: svc.host != "" && svc.subdomain != "");

      blackboxConfig = (pkgs.formats.yaml {}).generate "blackbox.yml" {
        modules.https = {
          prober = "http";
          timeout = "10s";
          http = {
            preferred_ip_protocol = "ip4";
            # Every service sits behind Caddy, which answers 502 when the
            # upstream is down; some (anki, share) legitimately 404 on `/`.
            valid_status_codes = range 200 499;
          };
        };
      };

      alert = name: expr: for: severity: summary: description: {
        alert = name;
        inherit expr for;
        labels = {inherit severity;};
        annotations = {inherit summary description;};
      };

      rules = {
        groups = [
          {
            name = "dendrix";
            rules = [
              {
                alert = "Watchdog";
                expr = "vector(1)";
                labels.severity = "none";
                annotations.summary = "Heartbeat proving the alerting pipeline works";
              }
              (alert "MonitorIsolated" ''sum(up{job="node", host!="${hostname}"}) == 0'' "2m" "critical"
                "${hostname} cannot reach any other server"
                "Every remote node exporter is unreachable, so ${hostname}'s own network is the likely cause. Host and service alerts are muted until it recovers.")
              (alert "HostDown" ''up{job="node"} == 0'' "5m" "critical"
                "{{ $labels.host }} is down"
                "The node exporter on {{ $labels.host }} has not answered for 5 minutes.")
              (alert "CaddyDown" ''node_systemd_unit_state{host="${caddy.host}", name="caddy.service", state="active"} == 0'' "2m" "critical"
                "Caddy is down on ${caddy.host}"
                "Every service behind Caddy is unreachable. Service alerts are muted until it recovers.")
              (alert "ServiceDown" ''probe_success{job="services"} == 0'' "5m" "critical"
                "{{ $labels.service }} is down"
                "{{ $labels.instance }} has failed its check for 5 minutes.")
              (alert "CertificateExpiring" ''probe_ssl_earliest_cert_expiry{job="services"} - time() < 7 * 86400'' "1h" "warning"
                "Certificate for {{ $labels.service }} expires soon"
                "The certificate served at {{ $labels.instance }} expires in {{ $value | humanizeDuration }}.")
              (alert "DiskAlmostFull" ''node_filesystem_avail_bytes{fstype!~"tmpfs|ramfs|squashfs|overlay"} / node_filesystem_size_bytes < 0.1 and node_filesystem_readonly == 0'' "15m" "warning"
                "{{ $labels.mountpoint }} on {{ $labels.host }} is almost full"
                "{{ $labels.mountpoint }} has {{ $value | humanizePercentage }} space left.")
              (alert "MemoryLow" "node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes < 0.1" "15m" "warning"
                "{{ $labels.host }} is low on memory"
                "Only {{ $value | humanizePercentage }} of memory is available.")
              (alert "NotificationsFailing" "increase(alertmanager_notifications_failed_total[15m]) > 0" "0m" "critical"
                "Alertmanager cannot deliver {{ $labels.integration }} notifications"
                "{{ $value | humanize }} {{ $labels.integration }} notifications to {{ $labels.receiver_name }} failed in the last 15 minutes.")
              (alert "SystemdUnitFailed" ''node_systemd_unit_state{state="failed"} == 1'' "5m" "warning"
                "{{ $labels.name }} failed on {{ $labels.host }}"
                "Run `journalctl -u {{ $labels.name }}` on {{ $labels.host }}.")
            ];
          }
        ];
      };
    in {
      services.prometheus = {
        enable = true;
        listenAddress = config.homelab.machineIP;
        inherit (prometheus) port;
        webExternalUrl = "https://${prometheus.fqdn}";
        retentionTime = "30d";
        globalConfig = {
          scrape_interval = "30s";
          evaluation_interval = "30s";
        };
        alertmanagers = [
          {
            static_configs = [
              {targets = ["${mkTsIp alertmanager.host}:${toString alertmanager.port}"];}
            ];
          }
        ];
        rules = [(builtins.toJSON rules)];
        scrapeConfigs = [
          {
            job_name = "node";
            static_configs =
              exporterHosts
              |> mapAttrsToList (name: host: let
                exporter = host.config.services.prometheus.exporters.node;
              in {
                targets = ["${exporter.listenAddress}:${toString exporter.port}"];
                labels = {
                  host = name;
                  instance = name;
                };
              });
          }
          {
            job_name = "alertmanager";
            static_configs = [
              {targets = ["${mkTsIp alertmanager.host}:${toString alertmanager.port}"];}
            ];
          }
          {
            job_name = "services";
            metrics_path = "/probe";
            params.module = ["https"];
            static_configs =
              probedServices
              |> mapAttrsToList (name: svc: {
                targets = ["https://${svc.fqdn}"];
                labels = {
                  service = name;
                  inherit (svc) host;
                };
              });
            relabel_configs = [
              {
                source_labels = ["__address__"];
                target_label = "__param_target";
              }
              {
                source_labels = ["__param_target"];
                target_label = "instance";
              }
              {
                target_label = "__address__";
                replacement = "${blackbox.listenAddress}:${toString blackbox.port}";
              }
            ];
          }
        ];

        exporters.blackbox = {
          enable = true;
          listenAddress = "127.0.0.1";
          configFile = blackboxConfig;
        };
      };

      systemd.services.prometheus.after = ["tailscaled.service"];
    };
  };
}
