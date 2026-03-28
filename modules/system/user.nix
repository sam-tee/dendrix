{
  flake.modules = {
    generic.userOption = {lib, ...}: {
      options.username = lib.mkOption {type = lib.types.str;};
    };
    nixos.user = {
      pkgs,
      config,
      ...
    }: let
      inherit (config) username;
    in {
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
        groups.media.gid = 951;
      };
    };
    nixos.homelab = {config, ...}: let
      inherit (config.homelab) group user dataDir;
    in {
      users = {
        users.${user} = {
          isSystemUser = true;
          inherit group;
          uid = 992;
          home = dataDir;
        };
        groups.${group}.gid = 951;
      };
    };
    darwin.user = {
      pkgs,
      config,
      ...
    }: let
      inherit (config) username;
    in {
      users.users.${username} = {
        description = username;
        name = username;
        shell = pkgs.zsh;
        ignoreShellProgramCheck = true;
      };
    };
  };
}
