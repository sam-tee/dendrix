{self, ...}: let
  theme = {
    file = "${self}/theme/theme.toml";
    defaultVariant = "dark";
    attrs = theme.file |> builtins.readFile |> fromTOML;
  };
in {
  flake.cosmetic = {
    bgFile = "${self}/theme/cassiopeia.jpg";
    cursor = {
      name = "Afterglow-Recolored-Catppuccin-Macchiato";
      mkPkg = pkgs: pkgs.afterglow-cursors-recolored;
      size = 24;
    };
    fonts = {
      size = 12;
      mono = {
        name = "Lilex Nerd Font Propo";
        mkPkg = pkgs: pkgs.nerd-fonts.lilex;
      };
      ui = {
        name = "Inter Variable";
        mkPkg = pkgs: pkgs.inter;
      };
    };
    inherit theme;
  };
}
