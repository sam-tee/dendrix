{
  config,
  inputs,
  lib,
  self,
  ...
}: let
  flakeInputs = lib.filterAttrs (name: value: (lib.isType "flake" value) && (name != "self")) inputs;
  remoteBuildMachines = [
    {
      hostName = "mba";
      systems = ["aarch64-darwin"];
      protocol = "ssh-ng";
      sshUser = "sam";
      maxJobs = 4;
      speedFactor = 1;
      supportedFeatures = [
        "benchmark"
        "big-parallel"
      ];
    }
    {
      hostName = "oracle";
      systems = ["aarch64-linux"];
      protocol = "ssh-ng";
      sshUser = "sam";
      maxJobs = 4;
      speedFactor = 1;
      supportedFeatures = [
        "benchmark"
        "big-parallel"
        "kvm"
        "nixos-test"
      ];
    }
    {
      hostName = "u410";
      systems = ["x86_64-linux"];
      protocol = "ssh-ng";
      sshUser = "sam";
      maxJobs = 4;
      speedFactor = 1;
      supportedFeatures = [
        "benchmark"
        "big-parallel"
        "kvm"
        "nixos-test"
      ];
    }
  ];
in {
  flake.modules = {
    generic.nix = _: {
      nix = {
        settings = {
          use-xdg-base-directories = true;
          keep-going = true;
          warn-dirty = false;
          builders-use-substitutes = true;
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
      nix = {
        buildMachines = remoteBuildMachines;
        distributedBuilds = true;
        optimise.automatic = true;
        channel.enable = false;
      };
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
      nix = {
        buildMachines = remoteBuildMachines;
        distributedBuilds = true;
        optimise.automatic = true;
        channel.enable = false;
      };
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
