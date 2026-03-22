{
  flake.modules.nixos.homelab = {lib, ...}: {
    options.homelab = {
      user = lib.mkOption {
        default = "media";
        type = lib.types.str;
        description = "User to run the homelab services as";
      };
      group = lib.mkOption {
        default = "media";
        type = lib.types.str;
        description = "Group to run homelab as";
      };
      domain = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Domain name to use";
        example = "zed.dev";
      };
      ingress = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {};
        description = "Mapping of subdomain names to their backend ports.";
        example = {nextcloud = "8080";};
      };
      tunnel = lib.mkOption {
        type = lib.types.str;
        default = "";
        example = "00000000-0000-0000-0000-000000000000";
        description = "ID of cloudflared tunnel";
      };
      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/drive";
        description = "Base directory to save data to";
      };
      email = {
        from = lib.mkOption {
          description = "The 'from' address";
          type = lib.types.str;
          default = "john@example.com";
        };
        host = lib.mkOption {
          description = "The SMTP server address";
          type = lib.types.str;
          default = "smtp.example.com";
        };
        user = lib.mkOption {
          description = "The SMTP username";
          type = lib.types.str;
          default = "john@example.com";
        };
        pwdPath = lib.mkOption {
          description = "Path to the secret containing SMTP password";
          type = lib.types.path;
        };
      };
    };
  };
}
