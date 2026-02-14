{
  flake-file.inputs.nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  flake.modules.darwin.brew = {
    inputs,
    username,
    ...
  }: {
    imports = [inputs.nix-homebrew.darwinModules.default];
    nix-homebrew = {
      enable = true;
      enableRosetta = true;
      user = username;
      autoMigrate = true;
    };

    homebrew = {
      enable = true;
      casks = [
        "ghostty"
        "google-chrome"
        "protonvpn"
        "raycast"
        "slicer"
        "spotify"
      ];
      masApps = {"Bitwarden" = 1352778147;};
      onActivation.cleanup = "zap";
    };
  };
}
