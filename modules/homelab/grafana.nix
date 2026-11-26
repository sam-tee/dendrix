{self, ...}: {
  flake.modules.nixos.grafana = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) getExe mkTsIp;
    inherit (self.services) grafana prometheus;
    inherit (config.services.grafana) dataDir;
    datasourceUid = "prometheus";

    generateSecrets = pkgs.writeShellApplication {
      name = "grafana-generate-secrets";
      runtimeInputs = [pkgs.coreutils];
      text = ''
        for name in secret-key admin-password; do
          file=${dataDir}/$name
          if [ ! -s "$file" ]; then
            head -c 32 /dev/urandom | base64 | tr -d '/+=\n' > "$file"
          fi
        done
      '';
    };

    grafanaDashboard = id: revision: hash:
      pkgs.fetchurl {
        name = "grafana-dashboard-${toString id}.json";
        url = "https://grafana.com/api/dashboards/${toString id}/revisions/${toString revision}/download";
        inherit hash;
      };

    dashboards = pkgs.linkFarm "grafana-dashboards" {
      "node-exporter-full.json" = grafanaDashboard 1860 46 "sha256-5Y3cXcU11MkB+U2pZIvD49Wue2946Y4YW86LKJlhzqM=";
      # Exported with a `__inputs` datasource placeholder that only the import
      # UI fills in; file provisioning needs the uid baked in.
      "blackbox-http.json" =
        pkgs.runCommand "blackbox-http.json" {
          src = grafanaDashboard 13659 1 "sha256-nnBFWFDAqKUqTOYxOrkRPlVla4ioQZ6rqEqakdzUj1Q=";
          placeholder = "\${DS_PROMETHEUS}";
        } ''
          substitute "$src" "$out" --replace-fail "$placeholder" ${datasourceUid}
        '';
    };
  in {
    services.grafana = {
      enable = true;
      settings = {
        server = {
          http_addr = config.homelab.machineIP;
          http_port = grafana.port;
          domain = grafana.fqdn;
          root_url = "https://${grafana.fqdn}";
        };
        security = {
          secret_key = "$__file{${dataDir}/secret-key}";
          admin_password = "$__file{${dataDir}/admin-password}";
        };
        "auth.anonymous" = {
          enabled = true;
          org_role = "Viewer";
        };
        analytics = {
          reporting_enabled = false;
          check_for_updates = false;
        };
      };
      provision = {
        enable = true;
        datasources.settings.datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            uid = datasourceUid;
            url = "http://${mkTsIp prometheus.host}:${toString prometheus.port}";
            isDefault = true;
          }
        ];
        dashboards.settings.providers = [
          {
            name = "dendrix";
            options.path = dashboards;
          }
        ];
      };
    };

    systemd.services.grafana = {
      after = ["tailscaled.service"];
      serviceConfig.ExecStartPre = [(getExe generateSecrets)];
    };
  };
}
