{self, ...}: {
  flake.modules.homeManager.noctalia = {
    programs.noctalia.customPalettes.akhlus = let
      palette = with self.cosmetic.theme.attrs; {
        mPrimary = base0E;
        mOnPrimary = base00;
        mSecondary = base0D;
        mOnSecondary = base01;
        mTertiary = base0B;
        mOnTertiary = base01;
        mError = base08;
        mOnError = base01;
        mSurface = base00;
        mOnSurface = base05;
        mSurfaceVariant = base02;
        mOnSurfaceVariant = base04;
        mOutline = base03;
        mShadow = base00;
        mHover = base0C;
        mOnHover = base01;
        terminal = {
          background = base00;
          foreground = base05;
          selectionFg = base05;
          selectionBg = base02;
          cursorText = base05;
          cursor = base05;
          normal = {
            black = base00;
            red = base08;
            green = base0B;
            yellow = base0A;
            blue = base0D;
            magenta = base0E;
            cyan = base0C;
            white = base05;
          };
          bright = {
            black = base03;
            red = base08;
            green = base0B;
            yellow = base0A;
            blue = base0D;
            magenta = base0E;
            cyan = base0C;
            white = "#ffffff";
          };
        };
      };
    in {
      dark = palette;
      light = palette;
    };
  };
}
