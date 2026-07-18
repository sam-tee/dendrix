{
  self,
  lib,
  ...
}: {
  options.flake.cosmetic = lib.mkOption {
    default = {};
    type = lib.types.submodule {
      options = {
        fonts = {
          mono = {
            name = lib.mkOption {
              type = lib.types.str;
              default = "Lilex Nerd Font Propo";
              description = "Name of monospace font to use";
            };
            pkgsName = lib.mkOption {
              type = lib.types.functionTo lib.types.package;
              default = pkgs: pkgs.nerd-fonts.lilex;
              description = "Package name of monospace font to use";
            };
          };
          ui = {
            name = lib.mkOption {
              type = lib.types.str;
              default = "Inter Variable";
              description = "Name of ui font to use";
            };
            pkgsName = lib.mkOption {
              type = lib.types.functionTo lib.types.package;
              default = pkgs: pkgs.inter;
              description = "Package name of ui font to use";
            };
          };
          size = lib.mkOption {
            type = lib.types.int;
            default = 12;
          };
        };
        cursor = {
          name = lib.mkOption {
            type = lib.types.str;
            default = "Afterglow-Recolored-Catppuccin-Macchiato";
            description = "Name of cursor to use";
          };
          pkgsName = lib.mkOption {
            type = lib.types.functionTo lib.types.package;
            default = pkgs: pkgs.afterglow-cursors-recolored;
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
          defaultVariant = lib.mkOption {
            type = lib.types.enum ["light" "dark"];
            default = "dark";
            description = "Variant of theme to use by default";
          };
          attrs = lib.mkOption {
            default = self.cosmetic.theme.file |> builtins.readFile |> fromTOML;
            description = "Theme to use. Must be either path to toml or attrset";
          };
        };
        bgFile = lib.mkOption {
          type = lib.types.path;
          default = ./cassiopeia.png;
          description = "Path to wallpaper";
        };
      };
    };
  };
}
