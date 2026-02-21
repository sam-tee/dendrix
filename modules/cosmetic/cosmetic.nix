{
  options = {lib, ...}: {
    cosmetic = {
      themeFile = lib.mkOption {
        type = lib.types.path;
        default = ./themes/akhlus.toml;
      };
      backgroundFile = lib.mkOption {
        type = lib.types.path;
        default = ./cassiopeia.png;
      };
    };
  };
  flake.modules.homeManager.cosmetic = {
    config,
    lib,
    ...
  }: let
    cfg = config.cosmetic;
  in {
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
      themeFileDir = lib.mkOption {
        type = lib.types.path;
        default = ./themes;
        description = "Path to a directory containing only the TOML files for each theme";
      };
      themes = lib.mkOption {
        type = lib.types.listOf lib.types.attrs;
        default = let
          dir = cfg.themeFileDir;
          files = builtins.attrNames (builtins.readDir dir);
          themePaths = map (name: dir + "/${name}") files;
          parseTOML = file: fromTOML (builtins.readFile file);
        in
          map parseTOML themePaths;
        description = "Attr set of theme variables automatically read from the themeFileDir provided";
        readOnly = true;
      };
    };
    config = {
      home.file = {${cfg.backgroundPath}.source = cfg.background;};
    };
  };
}
