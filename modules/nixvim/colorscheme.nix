{self, ...}: let
  inherit (self.cosmetic.theme) attrs defaultVariant;
in {
  flake.modules.nixvim.default = _: {
    colorschemes.base16 = {
      enable = true;
      colorscheme = attrs.${defaultVariant};
    };
  };
}
