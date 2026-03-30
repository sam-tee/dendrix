{
  inputs,
  lib,
  ...
}: {
  options.flake = {
    hosts = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          username = lib.mkOption {
            type = lib.types.str;
            default = "";
          };
          system = lib.mkOption {
            type = lib.types.str;
            default = "x86_64-linux";
          };
          pubKey = lib.mkOption {
            type = lib.types.str;
            default = "";
          };
          syncID = lib.mkOption {
            type = lib.types.str;
            default = "";
          };
        };
      });
      default = {};
    };
    lib = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      default = {};
    };
  };
  config.flake.modules.generic.hostOption = {lib, ...}: {
    options.host = {
      username = lib.mkOption {type = lib.types.str;};
      name = lib.mkOption {type = lib.types.str;};
    };
  };
  config.flake.lib = {
    mkNixos = name: let
      inherit (inputs.self.hosts.${name}) username system pubKey;
    in {
      ${name} = inputs.nixpkgs.lib.nixosSystem {
        modules = [
          inputs.self.modules.generic.hostOption
          inputs.self.modules.nixos."${name}Config"
          {
            host = {inherit name username;};
            networking.hostName = name;
            nixpkgs.hostPlatform = lib.mkDefault system;
            users.users.${username}.openssh.authorizedKeys.keys = [pubKey];
          }
        ];
      };
    };

    mkDarwin = name: let
      inherit (inputs.self.hosts.${name}) username system pubKey;
    in {
      ${name} = inputs.nix-darwin.lib.darwinSystem {
        modules = [
          inputs.self.modules.generic.hostOption
          inputs.self.modules.darwin."${name}Config"
          {
            host = {inherit name username;};
            networking.hostName = name;
            nixpkgs.hostPlatform = lib.mkDefault system;
            system.primaryUser = username;
            users.users.${username}.openssh.authorizedKeys.keys = [pubKey];
          }
        ];
      };
    };

    mkHome = name: let
      inherit (inputs.self.hosts.${name}) username system;
    in {
      ${name} = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        modules = [
          inputs.self.modules.generic.hostOption
          inputs.self.modules.homeManager."${name}Config"
          {
            host = {inherit name username;};
            nixpkgs.config.allowUnfree = true;
            inherit username;
          }
        ];
      };
    };
  };
}
