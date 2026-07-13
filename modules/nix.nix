{
  inputs,
  lib,
  self,
  ...
}: let
  flakeInputs = lib.filterAttrs (name: value: (lib.isType "flake" value) && (name != "self")) inputs;
  sshKeys = {
    "ssh/oracle".mode = "0600";
    "ssh/mba".mode = "0600";
    "ssh/u410".mode = "0600";
  };
  remoteBuildMachines = config: currentHostname:
    lib.optionals (currentHostname != "oracle") [
      {
        hostName = "oracle.scylla-goblin.ts.net:2222";
        systems = ["aarch64-linux"];
        protocol = "ssh-ng";
        sshUser = "sam";
        sshKey = config.sops.secrets."ssh/oracle".path;
        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUNibHRXL0ZUai9VSTRnOHZ3VndTTFZtbmltdndkRDJzMEx0d0tRV0szTTYgcm9vdEBvcmFjbGUK";
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
          extra-substituters = ["https://noctalia.cachix.org"];
          extra-trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];
          substituters = ["https://cache.akhlus.uk/dendrix?priority=30" "https://cache.nixos.org?priority=40"];
          trusted-public-keys = ["dendrix:gw3GtUeu7QiYchM+GKrwanxDeUqa/Ddl45l8x05rD+o=" "cache.nixos.org:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="];
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
    darwin.cli = {
      config,
      hostname ? config.networking.hostName,
      ...
    }: {
      imports = [self.modules.generic.nix];
      sops.secrets = sshKeys;
      nix = {
        buildMachines = remoteBuildMachines config hostname;
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

    nixos.cli = {
      config,
      hostname ? config.networking.hostName,
      pkgs,
      ...
    }: {
      imports = [self.modules.generic.nix];
      environment.variables.LD_LIBRARY_PATH = "$NIX_LD_LIBRARY_PATH";
      sops.secrets = sshKeys;
      nix = {
        buildMachines = remoteBuildMachines config hostname;
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
