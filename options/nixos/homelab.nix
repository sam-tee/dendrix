{self, ...}: {
  flake.modules.nixos.server = {
    config,
    lib,
    ...
  }: let
    inherit (lib) mkOption mkTsIp;
    inherit (lib.types) listOf path str;
  in {
    options.homelab = {
      backup = {
        paths = mkOption {
          type = listOf str;
          default = [];
          description = "Absolute paths on this host that the backup host copies nightly.";
        };
        databases = mkOption {
          type = listOf str;
          default = [];
          description = "PostgreSQL databases on this host to dump nightly, ready for the backup host to copy.";
        };
      };
      user = mkOption {
        default = "media";
        type = str;
        description = "User to run the homelab services as";
      };
      group = mkOption {
        default = "media";
        type = str;
        description = "Group to run homelab as";
      };
      caddyIP = mkOption {
        default = mkTsIp self.services.caddy.host;
      };
      machineIP = mkOption {
        default = mkTsIp config.networking.hostName;
      };
      dataDir = mkOption {
        type = str;
        default = "/mnt/data";
        description = "Base directory to save data to";
      };
      email = {
        from = mkOption {
          description = "The 'from' address";
          type = str;
          default = "john@example.com";
        };
        host = mkOption {
          description = "The SMTP server address";
          type = str;
          default = "smtp.example.com";
        };
        user = mkOption {
          description = "The SMTP username";
          type = str;
          default = "john@example.com";
        };
        pwdPath = mkOption {
          description = "Path to the secret containing SMTP password";
          type = path;
        };
      };
    };
  };
}
