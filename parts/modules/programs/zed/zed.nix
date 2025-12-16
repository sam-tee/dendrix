{
  flake.modules.home.zed = {...}:{
    programs.zed-editor = {
      enable = true;
      installRemoteServer = true;
      userSettings = import ./_settings.nix;
      themes = import ./_themes.nix;
    };
  };
}
