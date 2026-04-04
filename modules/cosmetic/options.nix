{
  config,
  lib,
  ...
}: {
  options.cosmetic = {
    fonts = {
      mono = {
        name = lib.mkOption {
          type = lib.types.str;
          default = "Lilex Nerd Font Propo";
          description = "Name of monospace font to use";
        };
        pkgsName = lib.mkOption {
          type = lib.types.str;
          default = "nerd-fonts.lilex";
          description = "Package name of monospace font to use";
        };
      };
      ui = lib.mkOption {
        name = lib.mkOption {
          type = lib.types.str;
          default = "Inter Variable";
          description = "Name of ui font to use";
        };
        pkgsName = lib.mkOption {
          type = lib.types.str;
          default = "inter";
          description = "Package name of ui font to use";
        };
      };
      size = lib.mkOption {
        type = lib.types.int;
        default = 14;
      };
    };
    cursor = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "Afterglow-Recolored-Catppuccin-Macchiato";
        description = "Name of cursor to use";
      };
      pkgsName = lib.mkOption {
        type = lib.types.str;
        default = "afterglow-cursors-recolored";
        description = "Package name of cursor to use";
      };
      size = lib.mkOption {
        type = lib.types.int;
        default = 24;
        description = "Size of cursor to use";
      };
    };
    theme = {
      file = lib.mkOption {
        type = lib.types.path;
        default = ./theme.toml;
        description = "Path to TOML theme file";
      };
      attrs = lib.mkOption {
        default = fromTOML (builtins.readFile config.cosmetic.themeFile);
        description = "Theme to use for stylix. Must be either path to yaml or attrset";
      };
    };
    bgFile = lib.mkOption {
      type = lib.types.path;
      default = ./cassiopeia.png;
      description = "Path to wallpaper";
    };
  };
}
