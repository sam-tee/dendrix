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
    services = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          port = lib.mkOption {type = lib.types.int;};
          host = lib.mkOption {
            type = lib.types.str;
            description = "Name of tailscale host service runs on";
          };
          private = lib.mkOption {
            type = lib.types.bool;
            default = true;
          };
          subdomain = lib.mkOption {
            type = lib.types.str;
          };
        };
      });
    };
    lib = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      default = {};
    };
  };
  config.flake.lib = {
    mkNixos = name: let
      inherit (inputs.self.hosts.${name}) username system pubKey;
    in {
      ${name} = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {inherit name username;};
        modules = [
          inputs.self.modules.nixos."${name}Config"
          {
            networking.hostName = name;
            nixpkgs.hostPlatform = lib.mkDefault system;
            users.users.${username}.openssh.authorizedKeys.keys = [pubKey];
          }
        ];
      };
    };

    mkMobile = name: let
      inherit (inputs.self.hosts.${name}) username system pubKey;
    in {
      ${name} = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {inherit name username;};
        modules = [
          inputs.self.modules.nixos."${name}Config"
          (import "${inputs.mobile-nixos}/lib/configuration.nix" {device = system;})
          {
            networking.hostName = name;
            users.users.${username}.openssh.authorizedKeys.keys = [pubKey];
          }
        ];
      };
    };

    mkDarwin = name: let
      inherit (inputs.self.hosts.${name}) username system pubKey;
    in {
      ${name} = inputs.nix-darwin.lib.darwinSystem {
        specialArgs = {inherit name username;};
        modules = [
          inputs.self.modules.darwin."${name}Config"
          {
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
        extraSpecialArgs = {inherit name username;};
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        modules = [
          inputs.self.modules.homeManager."${name}Config"
          {
            nixpkgs.config.allowUnfree = true;
            inherit username;
          }
        ];
      };
    };
  };
}
