{config, ...}: let
  userTheme = config.cosmetic.theme;
in {
  flake.modules.homeManager.zed = {lib, ...}: {
    programs.zed-editor = {
      enable = true;
      installRemoteServer = true;
      userSettings = import ./_settings.nix;
      themes.akhlus = import ./_theme.nix {inherit lib userTheme;};
    };
  };
}
