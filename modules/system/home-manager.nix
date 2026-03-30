{
  inputs,
  self,
  ...
}: let
  stateVersion = "24.11";
  language.base = "en_GB.UTF-8";
  backupFileExtension = "bak";
in {
  flake.modules = {
    darwin.hm = {
      lib,
      config,
      ...
    }: let
      inherit (config.host) username;
    in {
      imports = [inputs.home-manager.darwinModules.home-manager];
      home-manager = {
        inherit backupFileExtension;
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
    nixos.hm = {config, ...}: let
      inherit (config.host) username;
    in {
      imports = [inputs.home-manager.nixosModules.home-manager];
      home-manager = {
        inherit backupFileExtension;
        users.${username} = {
          home = {
            inherit username stateVersion language;
            homeDirectory = "/home/${username}";
          };
          programs.home-manager.enable = true;
        };
      };
    };
    homeManager.standalone = {config, ...}: let
      inherit (config.host) username;
    in {
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
