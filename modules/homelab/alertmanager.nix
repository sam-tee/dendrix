{
  lib,
  self,
  ...
}: let
  inherit (lib) escapeShellArg getExe mkTsIp;
  inherit (self.services) alertmanager caddy ntfy;
  ntfyUrl = "http://${mkTsIp ntfy.host}:${toString ntfy.port}";
  ntfyTopic = "dendrix";
in {
  flake.modules.nixos = {
    alertmanager = {config, ...}: let
      inherit (config.homelab.email) from host to user pwdPath;
      bridge = config.services.prometheus.alertmanager-ntfy.settings.http.addr;
      smtpPasswordCredential = "smtp-password";
    in {
      services.prometheus = {
        alertmanager = {
          enable = true;
          listenAddress = config.homelab.machineIP;
          inherit (alertmanager) port;
          webExternalUrl = "https://${alertmanager.fqdn}";
          # A single instance; an empty address stops the HA gossip listener
          # on 0.0.0.0:9094.
          extraFlags = ["--cluster.listen-address="];
          configuration = {
            global = {
              smtp_smarthost = "${host}:587";
              smtp_from = from;
              smtp_auth_username = user;
              smtp_auth_password_file = "/run/credentials/alertmanager.service/${smtpPasswordCredential}";
            };
            route = {
              receiver = "ntfy";
              group_by = ["alertname" "host"];
              group_wait = "30s";
              group_interval = "5m";
              repeat_interval = "12h";
              # ntfy cannot deliver alerts about its own outage, so those also go by email.
              routes = [
                {
                  matchers = [''alertname="Watchdog"''];
                  receiver = "null";
                }
                {
                  matchers = [''alertname="HostDown"'' ''host="${ntfy.host}"''];
                  receiver = "email";
                  continue = true;
                }
                {
                  matchers = [''alertname="ServiceDown"'' ''service="ntfy"''];
                  receiver = "email";
                  continue = true;
                }
                {
                  matchers = [''alertname="NotificationsFailing"'' ''integration="webhook"''];
                  receiver = "email";
                  continue = true;
                }
                {receiver = "ntfy";}
              ];
            };
            receivers = [
              {name = "null";}
              {
                name = "ntfy";
                webhook_configs = [{url = "http://${bridge}/hook";}];
              }
              {
                name = "email";
                email_configs = [
                  {
                    inherit to;
                    send_resolved = true;
                  }
                ];
              }
            ];
            inhibit_rules = [
              {
                source_matchers = [''alertname="MonitorIsolated"''];
                target_matchers = [''alertname=~"HostDown|ServiceDown|CertificateExpiring"''];
              }
              {
                source_matchers = [''alertname="HostDown"''];
                target_matchers = [''alertname="ServiceDown"''];
                equal = ["host"];
              }
              {
                source_matchers = [''alertname="CaddyDown"''];
                target_matchers = [''alertname="ServiceDown"''];
              }
              {
                source_matchers = [''alertname="HostDown"'' ''host="${caddy.host}"''];
                target_matchers = [''alertname="ServiceDown"''];
              }
            ];
          };
        };

        alertmanager-ntfy = {
          enable = true;
          # Straight to ntfy over the tailnet, so alerts still arrive when
          # Caddy or Cloudflare is what broke.
          settings.ntfy = {
            baseurl = ntfyUrl;
            notification.topic = ntfyTopic;
          };
        };
      };

      systemd.services.alertmanager = {
        waitForTailscaleIP = true;
        serviceConfig.LoadCredential = ["${smtpPasswordCredential}:${pwdPath}"];
      };
    };

    ntfy = {pkgs, ...}: let
      failuresBeforeAlert = 3;
      watchdogQuery = "http://${mkTsIp alertmanager.host}:${toString alertmanager.port}/api/v2/alerts?active=true&filter=alertname%3D%22Watchdog%22";
      check = pkgs.writeShellApplication {
        name = "alertmanager-heartbeat";
        runtimeInputs = with pkgs; [coreutils curl jq];
        text = ''
          state="$STATE_DIRECTORY/failures"
          failures="$(cat "$state" 2>/dev/null || echo 0)"

          notify() {
            curl -fsS --max-time 15 \
              -H "Title: $1" -H "Priority: $2" -H "Tags: $3" -d "$4" \
              ${escapeShellArg "${ntfyUrl}/${ntfyTopic}"} >/dev/null
          }

          if curl -fsS --max-time 10 ${escapeShellArg watchdogQuery} | jq -e 'length > 0' >/dev/null; then
            if [ "$failures" -ge ${toString failuresBeforeAlert} ]; then
              notify "Resolved: monitoring on ${alertmanager.host} is back" default green_circle \
                "The Watchdog alert is reaching Alertmanager on ${alertmanager.host} again."
            fi
            failures=0
          else
            failures=$((failures + 1))
            if [ "$failures" -eq ${toString failuresBeforeAlert} ]; then
              notify "Monitoring on ${alertmanager.host} is down" high red_circle \
                "${ntfy.host} has not seen the Watchdog alert in Alertmanager on ${alertmanager.host} for ${toString failuresBeforeAlert} checks in a row, so no other alerts can be sent."
            fi
          fi
          echo "$failures" > "$state"
        '';
      };
    in {
      systemd = {
        services.alertmanager-heartbeat = {
          description = "Check that ${alertmanager.host}'s Alertmanager still receives the Watchdog alert";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = getExe check;
            DynamicUser = true;
            StateDirectory = "alertmanager-heartbeat";
          };
        };
        timers.alertmanager-heartbeat = {
          wantedBy = ["timers.target"];
          timerConfig = {
            OnBootSec = "5min";
            OnUnitActiveSec = "2min";
          };
        };
      };
    };
  };
}
