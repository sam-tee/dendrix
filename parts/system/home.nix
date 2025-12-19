{
  flake.modules.darwin.hm = {
    inputs,
    lib,
    username,
    ...
  }: {
    imports = [inputs.home-manager.darwinModules.home-manager];
    home-manager = {
      backupFileExtension = "bak";
      extraSpecialArgs = {inherit inputs username;};
      users.${username} = {
        programs.ghostty.package = null;
        home = {
          username = username;
          homeDirectory = lib.mkForce "/Users/${username}";
          sessionPath = ["/opt/homebrew/bin"];
          stateVersion = "24.11";
          language.base = "en_GB.UTF-8";
        };
      };
    };
  };
  flake.modules.nixos.hm = {
    inputs,
    username,
    ...
  }: {
    imports = [inputs.home-manager.nixosModules.home-manager];
    home-manager = {
      backupFileExtension = "bak";
      extraSpecialArgs = {inherit inputs username;};
      users.${username}.home = {
        username = username;
        homeDirectory = "/home/${username}";
        stateVersion = "24.11";
        language.base = "en_GB.UTF-8";
      };
    };
  };
  flake.modules.homeManager.standalone = {username, ...}: {
    home = {
      username = username;
      homeDirectory = "/home/${username}";
      sessionVariables = {SSH_AUTH_SOCK = "$HOME/.bitwarden-ssh-agent.sock";};
      stateVersion = "24.11";
      language.base = "en_GB.UTF-8";
      keyboard.layout = "gb";
    };
  };
}
