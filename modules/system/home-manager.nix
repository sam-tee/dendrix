{
  inputs,
  self,
  ...
}: let
  stateVersion = "24.11";
  language.base = "en_GB.UTF-8";
  backupFileExtension = "bak";
  overwriteBackup = true;
in {
  flake.modules = {
    darwin.hm = {
      hostname,
      lib,
      username,
      ...
    }: {
      imports = [inputs.home-manager.darwinModules.home-manager];
      home-manager = {
        inherit backupFileExtension overwriteBackup;
        extraSpecialArgs = {inherit hostname username;};
        users.${username} = {
          programs.home-manager.enable = true;
          home = {
            inherit username stateVersion language;
            homeDirectory = lib.mkForce "/Users/${username}";
            sessionPath = ["/opt/homebrew/bin"];
          };
        };
      };
    };
    nixos.hm = {
      hostname,
      username,
      ...
    }: {
      imports = [inputs.home-manager.nixosModules.home-manager];
      home-manager = {
        inherit backupFileExtension overwriteBackup;
        extraSpecialArgs = {inherit hostname username;};
        users.${username} = {
          home = {
            inherit username stateVersion language;
            homeDirectory = "/home/${username}";
          };
          programs.home-manager.enable = true;
        };
      };
    };

    homeManager.standalone = {username, ...}: {
      imports = [self.modules.homeManager.nix];
      home = {
        inherit username stateVersion language;
        homeDirectory = "/home/${username}";
        keyboard.layout = "gb";
      };
      programs.home-manager.enable = true;
    };
  };
}
