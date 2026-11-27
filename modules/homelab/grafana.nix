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

    datasource = {
      type = "prometheus";
      uid = datasourceUid;
    };

    nodeExporterUid = "rYdddlPWk";
    blackboxUid = "NEzutrbMk";

    upDownMappings = [
      {
        type = "value";
        options = {
          "0" = {
            text = "Down";
            color = "red";
          };
          "1" = {
            text = "Up";
            color = "green";
          };
        };
      }
    ];

    instantTable = refId: expr: {
      inherit refId expr datasource;
      instant = true;
      format = "table";
    };

    byName = name: properties: {
      matcher = {
        id = "byName";
        options = name;
      };
      inherit properties;
    };

    usageColumn = name:
      byName name [
        {
          id = "unit";
          value = "percentunit";
        }
        {
          id = "decimals";
          value = 0;
        }
        {
          id = "custom.cellOptions";
          value.type = "color-text";
        }
        {
          id = "thresholds";
          value = {
            mode = "absolute";
            steps = [
              {
                color = "green";
                value = null;
              }
              {
                color = "orange";
                value = 0.8;
              }
              {
                color = "red";
                value = 0.9;
              }
            ];
          };
        }
      ];

    alertsPanel = {
      title = "Firing alerts";
      type = "table";
      inherit datasource;
      gridPos = {
        x = 0;
        y = 0;
        w = 24;
        h = 5;
      };
      targets = [(instantTable "alerts" ''ALERTS{alertstate="firing", alertname!="Watchdog"}'')];
      fieldConfig.defaults.noValue = "None";
      transformations = [
        {
          id = "filterFieldsByName";
          options.include.names = ["alertname" "host" "service" "severity"];
        }
        {
          id = "organize";
          options = {
            indexByName = {
              alertname = 0;
              host = 1;
              service = 2;
              severity = 3;
            };
            renameByName = {
              alertname = "Alert";
              host = "Host";
              service = "Service";
              severity = "Severity";
            };
          };
        }
      ];
    };

    servicesPanel = {
      title = "Services";
      type = "stat";
      inherit datasource;
      gridPos = {
        x = 0;
        y = 5;
        w = 24;
        h = 7;
      };
      # A range query because Prometheus sorts matrix results by label set,
      # which keeps the tiles in alphabetical order. The URL is copied to
      # `url` because `instance` sorts before `service` and would order the
      # tiles by subdomain instead.
      targets = [
        {
          refId = "services";
          expr = ''max by (service, url) (label_replace(probe_success{job="services"}, "url", "$1", "instance", "(.*)"))'';
          legendFormat = "{{service}}";
          inherit datasource;
        }
      ];
      fieldConfig.defaults = {
        links = [
          {
            title = "Open \${__field.labels.service}";
            url = "\${__field.labels.url}";
            targetBlank = true;
          }
          {
            title = "Probe details";
            url = "/d/${blackboxUid}?var-job=services&var-instance=\${__field.labels.url}";
          }
        ];
        mappings = upDownMappings;
        color.mode = "thresholds";
        thresholds = {
          mode = "absolute";
          steps = [
            {
              color = "red";
              value = null;
            }
            {
              color = "green";
              value = 1;
            }
          ];
        };
      };
      options = {
        reduceOptions = {
          calcs = ["lastNotNull"];
          values = false;
        };
        textMode = "name";
        colorMode = "background";
        graphMode = "none";
        justifyMode = "center";
      };
    };

    hostsPanel = {
      title = "Hosts";
      type = "table";
      inherit datasource;
      options.sortBy = [{displayName = "Host";}];
      gridPos = {
        x = 0;
        y = 12;
        w = 24;
        h = 7;
      };
      targets = [
        (instantTable "up" ''max by (host) (up{job="node"})'')
        (instantTable "uptime" "max by (host) (time() - node_boot_time_seconds)")
        # Clamped because idle time on VMs can run slightly ahead of wall
        # time, making usage come out negative.
        (instantTable "cpu" ''clamp_min(1 - avg by (host) (rate(node_cpu_seconds_total{mode="idle"}[5m])), 0)'')
        (instantTable "memory" "max by (host) (1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)")
        (instantTable "disk" ''max by (host) (1 - node_filesystem_avail_bytes{fstype!~"tmpfs|ramfs|squashfs|overlay"} / node_filesystem_size_bytes)'')
      ];
      transformations = [
        {
          id = "merge";
          options = {};
        }
        {
          id = "organize";
          options = {
            excludeByName.Time = true;
            indexByName = {
              host = 0;
              "Value #up" = 1;
              "Value #uptime" = 2;
              "Value #cpu" = 3;
              "Value #memory" = 4;
              "Value #disk" = 5;
            };
            renameByName = {
              host = "Host";
              "Value #up" = "Status";
              "Value #uptime" = "Uptime";
              "Value #cpu" = "CPU";
              "Value #memory" = "Memory";
              "Value #disk" = "Fullest disk";
            };
          };
        }
      ];
      fieldConfig = {
        defaults = {};
        overrides = [
          (byName "Host" [
            {
              id = "links";
              value = [
                {
                  title = "Host details";
                  url = "/d/${nodeExporterUid}?var-job=node&var-nodename=\${__value.raw}&var-node=\${__value.raw}";
                }
              ];
            }
          ])
          (byName "Status" [
            {
              id = "mappings";
              value = upDownMappings;
            }
            {
              id = "custom.cellOptions";
              value.type = "color-background";
            }
          ])
          (byName "Uptime" [
            {
              id = "unit";
              value = "s";
            }
            {
              id = "decimals";
              value = 0;
            }
          ])
          (usageColumn "CPU")
          (usageColumn "Memory")
          (usageColumn "Fullest disk")
        ];
      };
    };

    homeDashboard = pkgs.writeText "homelab.json" (builtins.toJSON {
      uid = "homelab";
      title = "Homelab";
      schemaVersion = 39;
      refresh = "1m";
      time = {
        from = "now-15m";
        to = "now";
      };
      timepicker.hidden = true;
      links = [
        {
          title = "Host details";
          type = "link";
          url = "/d/${nodeExporterUid}";
          icon = "dashboard";
        }
        {
          title = "Service details";
          type = "link";
          url = "/d/${blackboxUid}";
          icon = "dashboard";
        }
      ];
      panels = [alertsPanel servicesPanel hostsPanel];
    });

    grafanaDashboard = id: revision: hash:
      pkgs.fetchurl {
        name = "grafana-dashboard-${toString id}.json";
        url = "https://grafana.com/api/dashboards/${toString id}/revisions/${toString revision}/download";
        inherit hash;
      };

    dashboards = pkgs.linkFarm "grafana-dashboards" {
      "homelab.json" = homeDashboard;
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
        dashboards.default_home_dashboard_path = "${homeDashboard}";
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
