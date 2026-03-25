{
  inputs,
  lib,
  ...
}: let
  flakeInputs = lib.filterAttrs (name: value: (lib.isType "flake" value) && (name != "self")) inputs;
  nh = {
    enable = true;
    flake = "$HOME/dendrix";
    clean.enable = true;
  };
  nixDefault = {
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
      programs = {
        inherit nh;
        nix-ld = {
          enable = true;
          libraries = with pkgs; [
            stdenv.cc.cc.lib
            zlib
          ];
        };
      };
      environment.variables.LD_LIBRARY_PATH = "$NIX_LD_LIBRARY_PATH";
    };
    darwin.cli = {pkgs, ...}: {
      inherit nix nixpkgs;
      environment.systemPackages = devPkgs pkgs;
    };
    homeManager = {
      cli = {
        inherit nixpkgs;
        programs = {inherit nh;};
      };
      nix = {pkgs, ...}: {
        inherit nixpkgs;
        nix = nixDefault // {package = pkgs.nix;};
        home.packages = devPkgs pkgs;
      };
    };
  };
}
