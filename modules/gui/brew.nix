{inputs, ...}: {
  flake-file.inputs.nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  flake.modules.darwin.brew = {username, ...}: {
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
        "google-chrome"
        "helium-browser"
        "iina"
        "keepassxc"
        "mullvad-vpn"
        "protonvpn"
        "raycast"
        "skim"
        "slicer"
        "spotify"
        "zotero"
      ];
      masApps = {"Bitwarden" = 1352778147;};
      onActivation.cleanup = "zap";
    };
  };
}
