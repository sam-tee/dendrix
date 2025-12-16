{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.dendrix;
  mkUser = extraOptions:
    {
      description = cfg.username;
      name = cfg.username;
      shell = cfg.shell;
      ignoreShellProgramCheck = true;
    }
    // extraOptions;
in {
    flake.modules.nixos.user = {
      users.users.${cfg.username} = mkUser {
        extraGroups = ["networkmanager" "wheel"];
        isNormalUser = true;
      };
    };
    flake.modules.darwin.user = {
      users.users.${cfg.username} = mkUser {};
    };
}
