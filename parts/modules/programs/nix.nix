{config, ...}: let
  nix = {
    gc = {
      automatic = true;
      options = "-d";
    };
    optimise.automatic = true;
    settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = config.primaryUser.username;
    };
    registry."dendrix".to = {
      type = "github";
      owner = "sam-tee";
      repo = "dendrix";
    };
  };
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [];
  };
in {
  flake.modules.nixos.cli = {
    inherit nix nixpkgs;
  };
  flake.modules.darwin.cli = {
    inherit nix nixpkgs;
  };
  flake.modules.home.cli = {
    inherit nix nixpkgs;
  };
}
