{inputs, ...}: {
  flake-file.inputs = {
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };
  flake.modules.darwin.brew = {username, ...}: {
    imports = [inputs.nix-homebrew.darwinModules.default];
    nix-homebrew = {
      enable = true;
      user = username;
      mutableTaps = false;
      taps = {
        "homebrew/homebrew-core" = inputs.homebrew-core;
        "homebrew/homebrew-cask" = inputs.homebrew-cask;
      };
    };
    homebrew = {
      enable = true;
      casks = [
        "google-chrome"
        "helium-browser"
        "iina"
        "keepassxc"
        "protonvpn"
        "raycast"
        "skim"
        "spotify"
        "whatsapp"
        "zotero"
      ];
      masApps = {"Bitwarden" = 1352778147;};
      onActivation.cleanup = "zap";
    };
  };
}
