{
  flake.modules.nixos.homelab = {
    config,
    lib,
    ...
  }: let
    cfg = config.homelab;
  in {
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
    };
    config = {
      users = {
        users.${cfg.user} = {
          isSystemUser = true;
          inherit (cfg) group;
          home = "/var/lib/media";
        };
        groups.${cfg.group} = {};
      };
    };
  };
}
