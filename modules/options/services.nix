{lib, ...}: let
  inherit (lib) mkOption types;
  inherit (types) attrsOf int str submodule;
in {
  options.flake.services = mkOption {
    type = attrsOf (submodule {
      options = {
        port = mkOption {
          type = int;
          default = 0;
          description = "TCP port exposed by the service, or null when it has no listener";
        };
        host = mkOption {
          type = str;
          default = "";
          description = "Name of the NixOS host the service runs on, or null when dormant";
        };
        fqdn = mkOption {
          type = str;
          default = "";
          description = "Fully qualified domain name service runs on";
          example = "git.domain.com";
        };
      };
    });
  };
}
