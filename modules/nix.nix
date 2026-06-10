{
  config,
  inputs,
  lib,
  self,
  ...
}: let
  flakeInputs = lib.filterAttrs (name: value: (lib.isType "flake" value) && (name != "self")) inputs;
in {
  flake-file.nixConfig = {
    use-xdg-base-directories = true;
    keep-going = true;
    warn-dirty = false;
    builders-use-substitutes = true;
    accept-flake-config = false;
    flake-registry = "";
    experimental-features = [
      "flakes"
      "nix-command"
      "pipe-operators"
      "auto-allocate-uids"
    ];
    trusted-users = [
      "root"
      "@build"
      "@wheel"
      "@admin"
    ];
  };
  flake.modules = {
    generic.nix = _: {
      nix = {
        settings = config.flake-file.nixConfig;
        registry =
          (flakeInputs |> builtins.mapAttrs (_: flake: {inherit flake;}))
          // rec {
            nixpkgs = lib.mkForce {flake = inputs.nixpkgs;};
            n = nixpkgs;
          };
      };
      nixpkgs = {
        config = {
          allowUnfree = true;
          allowUnsupportedSystem = false;
          allowAliases = false;
          permittedInsecurePackages = ["electron-39.8.10"];
        };
        overlays = [];
      };
    };
    darwin.cli = _: {
      imports = [self.modules.generic.nix];
      nix.optimise.automatic = true;
      nix.channel.enable = false;
    };

    homeManager.cli = _: {
      imports = [self.modules.generic.nix];
      programs.nh = {
        enable = true;
        flake = "$HOME/dendrix";
        clean.enable = true;
      };
    };

    nixos.cli = {pkgs, ...}: {
      imports = [self.modules.generic.nix];
      environment.variables.LD_LIBRARY_PATH = "$NIX_LD_LIBRARY_PATH";
      nix.optimise.automatic = true;
      nix.channel.enable = false;
      programs = {
        nh = {
          enable = true;
          flake = "$HOME/dendrix";
          clean.enable = true;
        };
        nix-ld = {
          enable = true;
          libraries = with pkgs; [
            stdenv.cc.cc.lib
            zlib
          ];
        };
      };
    };
  };
}
