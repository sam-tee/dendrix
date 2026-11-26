{
  lib,
  self,
  ...
}: let
  inherit (lib) concatMapStringsSep escapeShellArg filterAttrs getExe mapAttrs mapAttrs' mapAttrsToList mkIf mkMerge mkTsIp nameValuePair;
  snapshotsKept = 14;
  sources =
    self.hosts
    |> filterAttrs (_: host: host.hostType == "server")
    |> mapAttrs (name: _: self.nixosConfigurations.${name}.config.homelab.backup.paths)
    |> filterAttrs (_: paths: paths != []);
in {
  flake.modules.nixos = {
    server = {
      config,
      pkgs,
      ...
    }: let
      cfg = config.homelab.backup;
    in
      mkMerge [
        (mkIf (cfg.paths != []) {
          environment.systemPackages = [pkgs.rsync];
        })
        (mkIf (cfg.databases != []) {
          services.postgresqlBackup = {
            enable = true;
            inherit (cfg) databases;
            compression = "zstd";
          };
          homelab.backup.paths = [config.services.postgresqlBackup.location];
        })
      ];

    backup = {
      config,
      hostname,
      pkgs,
      ...
    }: let
      mkPull = source: paths: let
        inherit (self.hosts.${source}) remoteBuilder username;
        remote = "${username}@${mkTsIp source}";
        knownHosts = pkgs.runCommand "${source}-known-hosts" {} ''
          printf '%s ' ${mkTsIp source} > $out
          base64 -d <<< ${remoteBuilder.publicHostKey} >> $out
        '';
      in
        pkgs.writeShellApplication {
          name = "backup-${source}";
          runtimeInputs = with pkgs; [coreutils findutils openssh rsync];
          text = ''
            dest=${escapeShellArg "${config.homelab.dataDir}/backups/${source}"}
            today="$(date +%F)"
            partial="$dest/$today.partial"

            mkdir -p "$dest"
            chmod 0700 "$dest"
            find "$dest" -mindepth 1 -maxdepth 1 -name '*.partial' ! -name "$today.partial" -exec rm -rf {} +

            link_dest=()
            if [ -d "$dest/latest" ]; then
              link_dest=(--link-dest="$dest/latest")
            fi

            rc=0
            rsync --archive --hard-links --numeric-ids --relative --delete \
              "''${link_dest[@]}" \
              --rsync-path="sudo rsync" \
              -e "ssh -i ${config.sops.secrets."ssh/${source}".path} -o BatchMode=yes -o StrictHostKeyChecking=yes -o UserKnownHostsFile=${knownHosts}" \
              ${concatMapStringsSep " " (path: escapeShellArg "${remote}:${path}") paths} \
              "$partial/" || rc=$?
            if [ "$rc" -ne 0 ] && [ "$rc" -ne 24 ]; then
              exit "$rc"
            fi

            rm -rf "''${dest:?}/$today"
            mv "$partial" "$dest/$today"
            ln -sfn "$today" "$dest/latest"

            find "$dest" -mindepth 1 -maxdepth 1 -type d -name '????-??-??' \
              | sort | head -n -${toString snapshotsKept} | xargs -r rm -rf
          '';
        };

      notifyFailure = pkgs.writeShellApplication {
        name = "backup-failed";
        runtimeInputs = [pkgs.curl];
        text = ''
          curl -fsS --max-time 15 \
            -H "Title: ${hostname} backup of $1 failed" \
            -H "Priority: high" \
            -H "Tags: warning,floppy_disk" \
            -d "journalctl -u backup-$1 on ${hostname}" \
            "https://${self.services.ntfy.fqdn}/dendrix" >/dev/null
        '';
      };
    in {
      assertions =
        sources
        |> mapAttrsToList (source: _: {
          assertion = self.hosts.${source}.remoteBuilder.publicHostKey != null;
          message = "backup: host '${source}' needs remoteBuilder.publicHostKey so its SSH host key can be pinned";
        });

      systemd = {
        services =
          (sources
            |> mapAttrs' (source: paths:
              nameValuePair "backup-${source}" {
                description = "Pull backups from ${source}";
                after = ["network-online.target" "tailscaled.service"];
                wants = ["network-online.target"];
                onFailure = ["backup-failed@${source}.service"];
                restartIfChanged = false;
                startLimitBurst = 3;
                startLimitIntervalSec = 2 * 60 * 60;
                serviceConfig = {
                  Type = "oneshot";
                  ExecStart = getExe (mkPull source paths);
                  Restart = "on-failure";
                  RestartMode = "direct";
                  RestartSec = "15min";
                  Nice = 19;
                  CPUSchedulingPolicy = "idle";
                  IOSchedulingClass = "idle";
                };
              }))
          // {
            "backup-failed@" = {
              description = "Notify ntfy that the backup of %i failed";
              serviceConfig = {
                Type = "oneshot";
                ExecStart = "${getExe notifyFailure} %i";
              };
            };
          };

        timers =
          sources
          |> mapAttrs' (source: _:
            nameValuePair "backup-${source}" {
              wantedBy = ["timers.target"];
              timerConfig = {
                OnCalendar = "*-*-* 03:00:00";
                Persistent = true;
                RandomizedDelaySec = "15min";
              };
            });
      };
    };
  };
}
