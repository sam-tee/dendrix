{lib, ...}: let
  inherit (lib) mkOption types;
  inherit (types) str submodule enum attrsOf;
in {
  options.flake.hosts = lib.mkOption {
    type = attrsOf (submodule {
      options = {
        username = lib.mkOption {
          type = str;
        };
        system = mkOption {
          type = str;
        };
        pubKey = mkOption {
          type = str;
          default = "";
        };
        syncID = mkOption {
          type = str;
          default = "";
        };
        hostType = mkOption {
          type = enum ["nixos" "darwin" "home" "other"];
          default = "other";
        };
        tailscaleIP = mkOption {
          type = str;
          default = "0.0.0.0"; # hacky but works to bind to all interfaces if no host provided
          description = "Tailscale IP of the host - used to bind services to";
        };
      };
    });
  };
}
