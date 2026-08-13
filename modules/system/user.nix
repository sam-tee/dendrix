{self, ...}: {
  flake.modules = let
    groupID = 991;
  in {
    nixos = {
      default = self.modules.nixos.user;
      user = {
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
              home = "/home/${username}";
              uid = 1000;
              hashedPasswordFile = config.sops.secrets.password.path;
              extraGroups = ["networkmanager" "samba" "wheel" "media" "dialout"];
              isNormalUser = true;
            };
          };
          groups.media.gid = groupID;
        };
      };
      server = {config, ...}: let
        inherit (config.homelab) group user dataDir;
      in {
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
    };
    darwin = {
      default = self.modules.darwin.user;
      user = {
        pkgs,
        username,
        ...
      }: {
        users.groups.media.gid = 991;
        users.users.${username} = {
          home = "/Users/${username}";
          description = username;
          name = username;
          shell = pkgs.zsh;
        };
      };
    };
  };
}
