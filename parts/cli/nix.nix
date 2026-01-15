let
  nixDefault = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["@wheel" "root"];
    };
    registry."dendrix".to = {
      type = "github";
      owner = "sam-tee";
      repo = "dendrix";
    };
  };
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
      inherit nixpkgs;
      nix = nixDefault // {optimise.automatic = true;};
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
      inherit nixpkgs;
      nix = nixDefault // {optimise.automatic = true;};
      environment.systemPackages = devPkgs pkgs;
    };
    homeManager.cli = {pkgs, ...}: {
      inherit nixpkgs;
      nix = nixDefault // {package = pkgs.nix;};
      home.packages = devPkgs pkgs;
    };
  };
}
