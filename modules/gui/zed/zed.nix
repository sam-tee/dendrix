{
  flake.modules.homeManager.zed = {
    config,
    lib,
    ...
  }: let
    userThemes = config.cosmetic.themes;
    zedThemes = import ./_theme.nix {inherit lib userThemes;};
  in {
    programs.zed-editor = {
      enable = true;
      installRemoteServer = true;
      userSettings = import ./_settings.nix {inherit config lib;};
      themes = zedThemes;
    };
  };
}
