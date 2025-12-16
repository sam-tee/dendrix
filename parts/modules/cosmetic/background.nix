{
  config,
  lib,
  ...
}: {
  options.background = {
    background = lib.mkOption {
      type = lib.types.path;
      default = ./cassiopeia.png;
      description = "Path to the file to use as background";
    };
    backgroundFile = lib.mkOption {
      type = lib.types.str;
      default = "Pictures/bg.png";
      description = "Where the background should be located with in the home folder";
    };
  };
    config = {
  flake.modules.home.background = {
      home.file = {${config.background.backgroundFile}.source = config.background.background;};
    };
  };
}
