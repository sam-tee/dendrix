{
  lib,
  self,
  ...
}: let
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
        subdomain = mkOption {
          type = str;
          default = "";
          description = "Subdomain to assign service to";
        };
        domain = mkOption {
          type = str;
          default = self.domain;
          description = "Domain to run service on";
        };
      };
    });
  };
}
