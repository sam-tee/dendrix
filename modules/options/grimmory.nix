{self, ...}: {
  flake.modules.nixos.grimmory = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.services.grimmory;
    managedPasswordFile = "${cfg.dataDir}/.db-password";
    usesExternalFile = cfg.databasePasswordFile != null;
  in {
    options.services.grimmory = {
      enable = lib.mkEnableOption "the grimmory service";

      package = lib.mkOption {
        type = lib.types.package;
        default = self.packages.${pkgs.stdenv.hostPlatform.system}.grimmory;
        defaultText = lib.literalExpression "self.packages.<system>.grimmory";
        description = "The grimmory package to run";
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "grimmory";
        description = "User to run the grimmory service as";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "grimmory";
        description = "Group to run the grimmory service as";
      };

      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/grimmory";
        description = "Base directory for grimmory data (config, bookdrop, password)";
      };

      port = lib.mkOption {
        type = lib.types.int;
        default = 6060;
        description = "Port grimmory listens on";
      };

      diskType = lib.mkOption {
        type = lib.types.enum ["LOCAL" "NETWORK"];
        default = "LOCAL";
        description = "Storage type grimmory should expect (LOCAL or NETWORK)";
      };

      databasePasswordFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        example = "/run/secrets/grimmory-db-pass";
        description = ''
          File containing the MariaDB password for the grimmory user, either
          as a raw password or in the form
          `SPRING_DATASOURCE_PASSWORD=<password>`. Typically provided by
          sops-nix. When set, the file must already exist when the database
          setup service runs (sops-nix secrets are installed during
          activation) and no password is generated; if it is missing the
          setup service fails rather than overwriting the secret. The password
          is normalized into `dataDir/.db-password`, which the app reads.
          When null, the password is managed in `dataDir/.db-password`, taken
          from `databasePassword` or generated on first activation.
        '';
      };

      databasePassword = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          Plaintext MariaDB password for the grimmory user, written to
          `dataDir/.db-password` when `databasePasswordFile` is null. Ignored
          when `databasePasswordFile` is set. Prefer a sops-nix secret via
          `databasePasswordFile`.
        '';
      };
    };

    config = lib.mkIf cfg.enable {
      services.mysql = {
        enable = true;
        package = pkgs.mariadb;
        initialDatabases = [{name = "grimmory";}];
      };

      systemd.tmpfiles.rules = [
        "d ${cfg.dataDir} 0750 ${cfg.user} ${cfg.group} -"
        "d ${cfg.dataDir}/data 0750 ${cfg.user} ${cfg.group} -"
        "d ${cfg.dataDir}/bookdrop 0750 ${cfg.user} ${cfg.group} -"
      ];

      systemd.services.grimmory-db = {
        description = "Grimmory database setup";
        after = ["mysql.service"];
        requires = ["mysql.service"];
        path = [pkgs.mariadb pkgs.coreutils pkgs.gnused];
        script = ''
          set -euo pipefail
          managed='${managedPasswordFile}'
          ${
            if usesExternalFile
            then ''
              source='${toString cfg.databasePasswordFile}'
              if [ ! -f "$source" ]; then
                echo "grimmory: database password file $source does not exist" >&2
                exit 1
              fi
              pw="$(sed -n 's/^SPRING_DATASOURCE_PASSWORD=//p' "$source" | head -n1)"
              if [ -z "$pw" ]; then
                pw="$(tr -d '\r\n' < "$source")"
              fi
              umask 077
              printf 'SPRING_DATASOURCE_PASSWORD=%s\n' "$pw" > "$managed"
              chown ${cfg.user}:${cfg.group} "$managed"
            ''
            else if cfg.databasePassword != null
            then ''
              pw='${lib.escapeShellArg cfg.databasePassword}'
              umask 077
              printf 'SPRING_DATASOURCE_PASSWORD=%s\n' "$pw" > "$managed"
              chown ${cfg.user}:${cfg.group} "$managed"
            ''
            else ''
              if [ ! -f "$managed" ]; then
                pw="$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32)"
                umask 077
                printf 'SPRING_DATASOURCE_PASSWORD=%s\n' "$pw" > "$managed"
                chown ${cfg.user}:${cfg.group} "$managed"
              fi
            ''
          }
          pw="$(sed -n 's/^SPRING_DATASOURCE_PASSWORD=//p' "$managed" | head -n1)"
          pw_sql="$(printf '%s' "$pw" | sed "s/'/'''/g")"
          mariadb --socket=/run/mysqld/mysqld.sock -u root <<SQL
          CREATE DATABASE IF NOT EXISTS grimmory CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
          CREATE USER IF NOT EXISTS 'grimmory'@'localhost' IDENTIFIED BY '$pw_sql';
          CREATE USER IF NOT EXISTS 'grimmory'@'%' IDENTIFIED BY '$pw_sql';
          ALTER USER 'grimmory'@'localhost' IDENTIFIED BY '$pw_sql';
          ALTER USER 'grimmory'@'%' IDENTIFIED BY '$pw_sql';
          GRANT ALL PRIVILEGES ON grimmory.* TO 'grimmory'@'localhost';
          GRANT ALL PRIVILEGES ON grimmory.* TO 'grimmory'@'%';
          FLUSH PRIVILEGES;
          SQL
        '';
      };

      systemd.services.grimmory = {
        description = "Grimmory";
        after = ["grimmory-db.service"];
        requires = ["grimmory-db.service"];
        path = [cfg.package];
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          User = cfg.user;
          Group = cfg.group;
          Restart = "on-failure";
          RestartSec = 10;
          ExecStart = "${lib.getExe cfg.package}";
          EnvironmentFile = managedPasswordFile;
        };
        environment = {
          APP_PATH_CONFIG = "${cfg.dataDir}/data";
          APP_BOOKDROP_FOLDER = "${cfg.dataDir}/bookdrop";
          DISK_TYPE = cfg.diskType;
          SPRING_DATASOURCE_URL = "jdbc:mariadb://127.0.0.1:3306/grimmory";
          SPRING_DATASOURCE_USERNAME = "grimmory";
          SERVER_PORT = toString cfg.port;
        };
      };
    };
  };
}
