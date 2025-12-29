{
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
      casks = ["ghostty" "protonvpn" "raycast" "spotify"];
      masApps = {"Bitwarden" = 1352778147;};
      onActivation.cleanup = "zap";
    };
  };
}
