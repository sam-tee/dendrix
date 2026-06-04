{
  flake.modules = let
    groupID = 991;
  in {
    nixos.user = {
      config,
      pkgs,
      username,
      ...
    }: {
      sops.secrets.password.neededForUsers = true;
      users = {
        mutableUsers = true;
        users = {
          root.hashedPasswordFile = config.sops.secrets.password.path;
          ${username} = {
            description = username;
            name = username;
            shell = pkgs.zsh;
            uid = 1000;
            hashedPasswordFile = config.sops.secrets.password.path;
            ignoreShellProgramCheck = true;
            extraGroups = ["networkmanager" "samba" "wheel" "media" "dialout"];
            isNormalUser = true;
          };
        };
        groups.media.gid = groupID;
      };
    };
    nixos.homelab = {config, ...}: let
      inherit (config.homelab) group user dataDir;
    in {
      security.sudo.wheelNeedsPassword = false;
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
