{lib, ...}: let
  inherit (lib) mkOption types;
  inherit (types) str submodule enum attrsOf;
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
          type = enum ["nixos" "darwin" "home" "other"];
          default = "other";
        };
      };
    });
  };
}
