{lib, ...}: let
  inherit (lib) mkOption types;
  inherit (types) str submodule enum attrsOf listOf;
in {
  options.flake.hosts = lib.mkOption {
    type = attrsOf (submodule {
      options = {
        username = lib.mkOption {
          type = str;
          default = "";
        };
        system = mkOption {
          type = str;
          default = "";
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
          type = enum ["server" "desktop" "darwin" "mobile" "other"];
          default = "other";
        };
        tailscaleIP = mkOption {
          type = str;
          default = "0.0.0.0"; # hacky but works to bind to all interfaces if no host provided
          description = "Tailscale IP of the host - used to bind services to";
        };
        modules = mkOption {
          type = listOf str;
          default = [];
          description = "Extra flake modules to import for this host, resolved in the mk* helper's namespace (e.g. self.modules.nixos). Desktop/server hosts also auto-import `<hostname>Hardware`, which must exist.";
        };
      };
    });
  };
}
