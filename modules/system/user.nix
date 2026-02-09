{
  flake.modules = {
    nixos.user = {
      pkgs,
      username,
      ...
    }: {
      users = {
        users.${username} = {
          description = username;
          name = username;
          shell = pkgs.zsh;
          uid = 1000;
          ignoreShellProgramCheck = true;
          extraGroups = ["networkmanager" "samba" "wheel" "media" "dialout"];
          isNormalUser = true;
        };
        groups.media.gid = 991;
      };
    };
    nixos.homelab = {
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
            uid = 992;
            home = "/var/lib/media";
          };
          groups.${group}.gid = 991;
        };
      };
    };
    darwin.user = {
      pkgs,
      username,
      ...
    }: {
      users.users.${username} = {
        description = username;
        name = username;
        shell = pkgs.zsh;
        ignoreShellProgramCheck = true;
      };
    };
  };
}
