{lib, ...}: let
  inherit (lib) mkOption types;
  inherit (types) str bool submodule int attrsOf;
in {
  options.flake.services = mkOption {
    type = attrsOf (submodule {
      options = {
        port = mkOption {type = int;};
        host = mkOption {
          type = str;
          description = "Name of tailscale host service runs on";
        };
        private = mkOption {
          type = bool;
          default = true;
          description = "Whether to only expose over tailscale";
        };
        subdomain = mkOption {
          type = str;
          description = "Subdomain to asign service to";
        };
      };
    });
  };
}
