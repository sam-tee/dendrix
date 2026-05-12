{self, ...}: let
  inherit (self.cosmetic) theme;
in {
  flake.modules.nixvim.default = _: {
    colorschemes.base16 = {
      enable = true;
      colorscheme = theme.colours;
    };
  };
}
