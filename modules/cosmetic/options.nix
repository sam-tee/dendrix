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
          attrs = lib.mkOption {
            default = self.cosmetic.theme.file |> builtins.readFile |> fromTOML;
            description = "Theme to use for stylix. Must be either path to yaml or attrset";
          };
          noHash = lib.mkOption {
            default = self.cosmetic.theme.attrs |> builtins.mapAttrs (name: value: lib.removePrefix "#" value);
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
