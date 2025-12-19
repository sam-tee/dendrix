{
  flake.modules.homeManager.zed = {
    config,
    lib,
    ...
  }: let
    inherit
      (import ./_theme.nix {
        theme = config.cosmetic.theme;
        inherit lib;
      })
      themeOut
      ;
  in {
    programs.zed-editor = {
      enable = true;
      installRemoteServer = true;
      userSettings = import ./_settings.nix;
      themes = {akhlus = themeOut;};
    };
  };
}
