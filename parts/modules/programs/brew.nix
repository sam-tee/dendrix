{
    flake.modules.darwin.cli = {
      config,
      inputs,
      ...
    }: {
      imports = [inputs.nix-homebrew.darwinModules.default];
      nix-homebrew = {
        enable = true;
        enableRosetta = true;
        user = config.primaryUser.username;
        autoMigrate = true;
      };

      homebrew = {
        enable = true;
        casks = ["ghostty" "spotify"];
        masApps = {"Bitwarden" = 1352778147;};
        onActivation.cleanup = "zap";
      };
    };
    flake.modules.home.brew = {
      home.sessionPath = ["/opt/homebrew/bin"];
    };
}
