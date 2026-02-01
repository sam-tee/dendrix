{
  flake.modules.nixos.homelab = {
    config,
    lib,
    ...
  }: {
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
    config = let
      inherit (config.homelab) group user;
    in {
      users = {
        users.${user} = {
          isSystemUser = true;
          inherit group;
          home = "/var/lib/media";
        };
        groups.${group} = {};
      };
    };
  };
}
