{
  inputs,
  lib,
  self,
  ...
}: let
  inherit (self.lib) mkRemoteBuilder;
  flakeInputs = lib.filterAttrs (name: value: (lib.isType "flake" value) && (name != "self")) inputs;
  remoteBuildMachines = config: currentHostname:
    [
      (mkRemoteBuilder config {
        hostname = "oracle";
        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUNibHRXL0ZUai9VSTRnOHZ3VndTTFZtbmltdndkRDJzMEx0d0tRV0szTTYgcm9vdEBvcmFjbGUK";
      })
      (mkRemoteBuilder config {
        hostname = "u410";
        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU00YTdrOFZXMDJDdlA1SUM3akx5S0h6MWpZSjI3QlpVRnBnYms4bDFvK0wgcm9vdEB1NDEwCg==";
        maxJobs = 2;
      })
    ]
    |> lib.filter (machine: (machine.hostName |> lib.splitString ":" |> lib.head) != currentHostname);
in {
  flake.modules = {
    generic.default = self.modules.generic.nix;
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
          extra-substituters = ["https://cache.${self.domain}/dendrix"];
          extra-trusted-public-keys = ["dendrix:lYCtmFj4pkP8VyJq0LryToQfVAXpMcRou8wPFKOw2xI="];
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
          // {
            nixpkgs = lib.mkForce {flake = inputs.nixpkgs;};
            den.flake = self;
          };
      };
      nixpkgs.config = {
        allowUnfree = true;
        allowUnsupportedSystem = false;
        allowAliases = false;
      };
    };

    nixos.default = self.modules.nixos.nix;
    nixos.nix = {pkgs, ...}: {
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
