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
          ignoreShellProgramCheck = true;
          extraGroups = ["networkmanager" "samba" "wheel" "media" "dialout"];
          isNormalUser = true;
        };
        groups.media = {};
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
