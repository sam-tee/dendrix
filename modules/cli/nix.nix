{
  inputs,
  lib,
  ...
}: let
  flakeInputs = lib.filterAttrs (name: value: (lib.isType "flake" value) && (name != "self")) inputs;
  nixDefault = {
    gc = {
      automatic = true;
      options = "--delete-older-than 3d";
    };
    registry =
      (builtins.mapAttrs (_: flake: {inherit flake;}) flakeInputs)
      // {nixpkgs = lib.mkForce {flake = inputs.nixpkgs;};};
    settings = {
      use-xdg-base-directories = true;
      keep-going = true;
      experimental-features = [
        "nix-command"
        "flakes"
        "auto-allocate-uids"
        "pipe-operators"
      ];
      trusted-users = [
        "@admin"
        "@wheel"
        "sam"
      ];
    };
  };
  nix = nixDefault // {optimise.automatic = true;};
  devPkgs = pkgs:
    with pkgs; [
      alejandra
      nixd
    ];
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [];
  };
in {
  flake.modules = {
    nixos.cli = {pkgs, ...}: {
      inherit nix nixpkgs;
      environment.systemPackages = devPkgs pkgs;
      programs.nix-ld = {
        enable = true;
        libraries = with pkgs; [
          stdenv.cc.cc.lib
          zlib
        ];
      };
      environment.variables.LD_LIBRARY_PATH = "$NIX_LD_LIBRARY_PATH";
    };
    darwin.cli = {pkgs, ...}: {
      inherit nix nixpkgs;
      environment.systemPackages = devPkgs pkgs;
    };
    homeManager = {
      cli = {inherit nixpkgs;};
      nix = {pkgs, ...}: {
        inherit nixpkgs;
        nix = nixDefault;
        home.packages = devPkgs pkgs;
      };
    };
  };
}
