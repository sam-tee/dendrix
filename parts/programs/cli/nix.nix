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
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [];
  };
in {
  flake.modules.nixos.cli = {
    inherit nixpkgs;
    nix = nixDefault // {optimise.automatic = true;};
  };
  flake.modules.darwin.cli = {
    inherit nixpkgs;
    nix = nixDefault // {optimise.automatic = true;};
  };
  flake.modules.homeManager.cli = {
    inherit nixpkgs;
    nix = nixDefault;
  };
}
