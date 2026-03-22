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
        groups.${group}.gid = 991;
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
