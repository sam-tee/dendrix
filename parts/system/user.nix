{
  flake.modules.nixos.user = {
    pkgs,
    username,
    ...
  }: {
    users.users.${username} = {
      description = username;
      name = username;
      shell = pkgs.zsh;
      ignoreShellProgramCheck = true;
      extraGroups = ["networkmanager" "wheel"];
      isNormalUser = true;
    };
  };
  flake.modules.darwin.user = {
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
}
