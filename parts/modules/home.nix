{inputs, ...}: let
  home-manager = {
    backupFileExtension = "bak";
  };
in {
  flake.modules.darwin.hm = {
    imports = [inputs.home-manager.darwinModules.home-manager];
    inherit home-manager;
  };
  flake.modules.nixos.hm = {
    imports = [inputs.home-manager.nixosModules.home-manager];
    inherit home-manager;
  };
  flake.modules.home.hm = {pkgs, ...}:{
    home = {
      username = username;
      homeDirectory = (
        if pkgs.stdenv.isDarwin
        then "/Users/${username}"
        else "/home/${username}"
      );
      sessionPath = lib.optionals pkgs.stdenv.isDarwin ["/opt/homebrew/bin"];
      sessionVariables =
        lib.mkIf (!pkgs.stdenv.isDarwin)
        {SSH_AUTH_SOCK = "/home/${username}/.bitwarden-ssh-agent.sock";};
      stateVersion = "24.11";
    };
  };
}
