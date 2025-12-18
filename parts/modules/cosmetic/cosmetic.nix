{
  flake.modules.home.background = {
    config,
    lib,
    ...
  }:{
  options.cosmetic = {
    background = lib.mkOption {
      type = lib.types.path;
      default = ./cassiopeia.png;
      description = "Path to the file to use as background";
    };
    backgroundPath = lib.mkOption {
      type = lib.types.str;
      default = "Pictures/bg.png";
      description = "Where the background should be located with in the home folder";
    };
      themeFile = lib.mkOption {
        type = lib.types.path;
        default = ./theme.toml;
        description = "Path to the theme TOML fie";
      };
      theme = lib.mkOption {
        type = lib.types.attrs;
        default = builtins.fromTOML (builtins.readFile config.theme.themeFile);
        description = "Attr set of theme variables automatically read from the themeFile provided";
      };
    };
    config = {
      home.file = {${config.background.backgroundFile}.source = config.background.background;};
    };
  };
}
