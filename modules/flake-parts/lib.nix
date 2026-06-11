{
  inputs,
  lib,
  ...
}: let
  inherit (lib) mkOption types;
  inherit (types) str bool submodule int oneOf attrsOf unspecified;
in {
  options.flake = {
    hosts = mkOption {
      type = attrsOf (submodule {
        options = {
          username = mkOption {
            type = str;
            default = "";
          };
          system = mkOption {
            type = str;
            default = "";
          };
          pubKey = mkOption {
            type = str;
            default = "";
          };
          syncID = mkOption {
            type = str;
            default = "";
          };
          hostType = mkOption {
            type = oneOf ["nixos" "darwin" "home"];
          };
        };
      });
    };
    services = mkOption {
      type = attrsOf (submodule {
        options = {
          port = mkOption {type = int;};
          host = mkOption {
            type = str;
            description = "Name of tailscale host service runs on";
          };
          private = mkOption {
            type = bool;
            default = true;
            description = "Whether to only expose over tailscale";
          };
          subdomain = mkOption {
            type = str;
            description = "Subdomain to asign service to";
          };
        };
      });
    };
    lib = mkOption {
      type = attrsOf unspecified;
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
          }
        ];
      };
    };
  };
}
