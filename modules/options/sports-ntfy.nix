{self, ...}: {
  flake.modules.nixos.sports-ntfy = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.services.sports-ntfy;
    settingsFormat = pkgs.formats.toml {};
    configFile = settingsFormat.generate "sports-notify-config.toml" cfg.settings;
  in {
    options.services.sports-ntfy = {
      enable = lib.mkEnableOption "sports-notify, a daemon pushing PL / MLB / NFL / NHL scores to ntfy";

      package = lib.mkOption {
        type = lib.types.package;
        default = self.packages.${pkgs.stdenv.hostPlatform.system}.sports-ntfy;
        defaultText = lib.literalExpression "self.packages.<system>.sports-notify";
        description = "The sports-notify package to run";
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "sports-notify";
        description = "User to run the sports-notify service as";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "sports-notify";
        description = "Group to run the sports-notify service as";
      };

      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/sports-notify";
        description = "Working directory where seen-game state is persisted";
      };

      host = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = "Host the service binds to";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 8423;
        description = "Port the service listens on";
      };

      settings = lib.mkOption {
        inherit (settingsFormat) type;
        default = {};
        description = ''
          Sports Notify configuration, written as TOML and passed via
          `--config`. See <https://github.com/> for available keys.
          Note the Nix store is world-readable, so keep secrets out.
        '';
        example = {
          ntfy = {
            server = "https://ntfy.sh";
            topic = "sports-x7Kq92m";
          };
          poll.interval_seconds = 30;
          baseball.teams = ["SEA"];
        };
      };

      environmentFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        example = "/run/secrets/sportsNotifyConfig";
        description = ''
          EnvironmentFile loaded by the service, typically a sops-nix secret
          holding credentials (e.g. ntfy auth) in `KEY=value` form.
        '';
      };
    };

    config = lib.mkIf cfg.enable {
      users.users.${cfg.user} = {
        isSystemUser = true;
        group = cfg.group;
        description = "sports-ntfy daemon user";
      };
      users.groups.${cfg.group} = {};

      systemd.services.sports-ntfy = {
        description = "Sports notifications (PL / MLB / NFL -> ntfy)";
        after = ["network-online.target"];
        wants = ["network-online.target"];
        wantedBy = ["multi-user.target"];

        serviceConfig = {
          User = cfg.user;
          Group = cfg.group;
          ExecStart = "${lib.getExe cfg.package} --config ${configFile}";
          EnvironmentFile = lib.mkIf (cfg.environmentFile != null) [cfg.environmentFile];
          WorkingDirectory = cfg.dataDir;
          StateDirectory = baseNameOf cfg.dataDir;
          Restart = "always";
          RestartSec = 30;
          NoNewPrivileges = true;
          PrivateTmp = true;
          PrivateDevices = true;
          ProtectSystem = "strict";
          ProtectHome = true;
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectKernelLogs = true;
          ProtectControlGroups = true;
          RestrictSUIDSGID = true;
          LockPersonality = true;
          RestrictRealtime = true;
          RestrictAddressFamilies = ["AF_INET" "AF_INET6"];
          ReadWritePaths = [cfg.dataDir];
        };
      };
    };
  };
}
