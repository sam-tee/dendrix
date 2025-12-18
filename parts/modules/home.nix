let
  username = "";
in {
  flake.modules.darwin.hm = {inputs, ...}: {
    imports = [inputs.home-manager.darwinModules.home-manager];
    home-manager = {
      backupFileExtension = "bak";
      users.${username}.home = {
        username = username;
        homeDirectory = "/Users/${username}";
        sessionPath = ["/opt/homebrew/bin"];
        stateVersion = "24.11";
      };
    };
  };
  flake.modules.nixos.hm = {inputs, ...}: {
    imports = [inputs.home-manager.nixosModules.home-manager];
    home-manager = {
      backupFileExtension = "bak";
      users.${username}.home = {
        username = username;
        homeDirectory = "/home/${username}";
        stateVersion = "24.11";
      };
    };
  };
  flake.modules.home.standalone = {
    home = {
      username = username;
      homeDirectory = "/home/${username}";
      sessionVariables = {SSH_AUTH_SOCK = "/home/${username}/.bitwarden-ssh-agent.sock";};
      stateVersion = "24.11";
    };
  };
}
