{
  config,
  lib,
  ...
}: {
  options.theme = {
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
}
