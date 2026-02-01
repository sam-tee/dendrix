let
  stateVersion = "24.11";
  language.base = "en_GB.UTF-8";
  backupFileExtension = "bak";
in {
  flake.modules = {
    darwin.hm = {
      inputs,
      lib,
      username,
      ...
    }: {
      imports = [inputs.home-manager.darwinModules.home-manager];
      home-manager = {
        inherit backupFileExtension;
        extraSpecialArgs = {inherit inputs username;};
        users.${username} = {
          programs.ghostty.package = null;
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
      inputs,
      username,
      ...
    }: {
      imports = [inputs.home-manager.nixosModules.home-manager];
      home-manager = {
        inherit backupFileExtension;
        extraSpecialArgs = {inherit inputs username;};
        users.${username} = {
          home = {
            inherit username stateVersion language;
            homeDirectory = "/home/${username}";
          };
          programs.home-manager.enable = true;
        };
      };
    };
    homeManager.standalone = {
      pkgs,
      username,
      ...
    }: {
      home = {
        inherit username stateVersion language;
        homeDirectory = "/home/${username}";
        keyboard.layout = "gb";
      };
      nix.package = pkgs.nix;
      programs.home-manager.enable = true;
    };
  };
}
