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
    [
      {
        hostName = "oracle:2222";
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
      {
        hostName = "u410:2222";
        systems = ["x86_64-linux"];
        protocol = "ssh-ng";
        sshUser = "sam";
        sshKey = config.sops.secrets."ssh/u410".path;
        publicHostKey = "";
        maxJobs = 2;
        speedFactor = 1;
        supportedFeatures = [
          "benchmark"
          "big-parallel"
          "kvm"
          "nixos-test"
        ];
      }
      {
        hostName = "mba:22";
        systems = ["aarch64-darwin"];
        protocol = "ssh-ng";
        sshUser = "sam";
        sshKey = config.sops.secrets."ssh/mba".path;
        publicHostKey = "";
        maxJobs = 4;
        speedFactor = 1;
        supportedFeatures = [
          "benchmark"
          "big-parallel"
          "kvm"
          "nixos-test"
        ];
      }
    ]
    |> lib.filter (machine: (machine.hostName |> lib.splitString ":" |> lib.head) != currentHostname);
in {
  flake.modules = {
    generic.nix = {
      config,
      hostname,
      ...
    }: {
      nix = {
        distributedBuilds = true;
        buildMachines = remoteBuildMachines config hostname;
        optimise.automatic = true;
        channel.enable = false;
        settings = {
          use-xdg-base-directories = true;
          keep-going = true;
          warn-dirty = false;
          builders-use-substitutes = true;
          extra-substituters = [
            "https://cache.akhlus.uk/dendrix"
            "https://noctalia.cachix.org"
          ];
          extra-trusted-public-keys = [
            "dendrix:MU7iD1cgxI5AAzaiuRCVRL3z7//2uRS+k5ZTKZX0HUk="
            "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
          ];
          flake-registry = "";
          experimental-features = [
            "flakes"
            "nix-command"
            "pipe-operators"
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

    darwin.default = self.modules.darwin.nix;
    darwin.nix = _: {
      imports = [self.modules.generic.nix];
      sops.secrets = sshKeys;
    };

    nixos.default = self.modules.nixos.nix;
    nixos.nix = {pkgs, ...}: {
      imports = [self.modules.generic.nix];
      environment.variables.LD_LIBRARY_PATH = "$NIX_LD_LIBRARY_PATH";
      sops.secrets = sshKeys;
      nix.settings = {
        use-cgroups = true;
        auto-allocate-uids = true;
        experimental-features = ["cgroups" "auto-allocate-uids"];
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
