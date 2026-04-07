{
  flake.modules = let
    groupID = 991;
  in {
    nixos.user = {
      pkgs,
      config,
      ...
    }: let
      inherit (config.host) username;
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
        groups.media.gid = groupID;
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
        groups.${group}.gid = groupID;
      };
    };
    darwin.user = {
      pkgs,
      config,
      ...
    }: let
      inherit (config.host) username;
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
