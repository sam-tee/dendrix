{
  config,
  lib,
  ...
}: {
  options.cosmetic = {
    themeFile = lib.mkOption {
      type = lib.types.path;
      default = ./themes/akhlus.toml;
      description = "Path to TOML theme file";
    };
    theme = lib.mkOption {
      default = fromTOML (builtins.readFile config.cosmetic.themeFile);
      description = "Theme to use for stylix. Must be either path to yaml or attrset";
    };
    backgroundFile = lib.mkOption {
      type = lib.types.path;
      default = ./cassiopeia.png;
    };
  };
}
