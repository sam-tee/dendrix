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
    mkNixos = hostname: let
      inherit (inputs.self.hosts.${hostname}) username system pubKey;
    in {
      ${hostname} = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {inherit hostname username;};
        modules = [
          inputs.self.modules.nixos."${hostname}Config"
          {
            networking.hostName = hostname;
            nixpkgs.hostPlatform = lib.mkDefault system;
            users.users.${username}.openssh.authorizedKeys.keys = [pubKey];
          }
        ];
      };
    };

    mkMobile = hostname: let
      inherit (inputs.self.hosts.${hostname}) username system pubKey;
    in {
      ${hostname} = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {inherit hostname username;};
        modules = [
          inputs.self.modules.nixos."${hostname}Config"
          (import "${inputs.mobile-nixos}/lib/configuration.nix" {device = system;})
          {
            networking.hostName = hostname;
            users.users.${username}.openssh.authorizedKeys.keys = [pubKey];
          }
        ];
      };
    };

    mkDarwin = hostname: let
      inherit (inputs.self.hosts.${hostname}) username system pubKey;
    in {
      ${hostname} = inputs.nix-darwin.lib.darwinSystem {
        specialArgs = {inherit hostname username;};
        modules = [
          inputs.self.modules.darwin."${hostname}Config"
          {
            networking.hostName = hostname;
            nixpkgs.hostPlatform = lib.mkDefault system;
            system.primaryUser = username;
            users.users.${username}.openssh.authorizedKeys.keys = [pubKey];
          }
        ];
      };
    };

    mkHome = hostname: let
      inherit (inputs.self.hosts.${hostname}) username system;
    in {
      ${hostname} = inputs.home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = {
          inherit hostname username;
        };
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        modules = [
          inputs.self.modules.homeManager."${hostname}Config"
          {
            nixpkgs.config.allowUnfree = true;
            inherit username;
          }
        ];
      };
    };
  };
}
