theme: let
  colors = {
    mError = "${theme.base08}";
    mHover = "${theme.base09}";
    mOnError = "${theme.base01}";
    mOnHover = "${theme.base01}";
    mOnPrimary = "${theme.base01}";
    mOnSecondary = "${theme.base01}";
    mOnSurface = "${theme.base05}";
    mOnSurfaceVariant = "${theme.base04}";
    mOnTertiary = "${theme.base01}";
    mOutline = "${theme.base03}";
    mPrimary = "${theme.base0E}";
    mSecondary = "${theme.base0D}";
    mShadow = "${theme.base01}";
    mSurface = "${theme.base00}";
    mSurfaceVariant = "${theme.base02}";
    mTertiary = "${theme.base0B}";
    terminal = {
      background = "${theme.base00}";
      cursor = "${theme.base05}";
      cursorText = "${theme.base00}";
      foreground = "${theme.base05}";
      bright = {
        black = "${theme.base03}";
        blue = "${theme.base0D}";
        cyan = "${theme.base0C}";
        green = "${theme.base0B}";
        magenta = "${theme.base0E}";
        red = "${theme.base08}";
        white = "${theme.base07}";
        yellow = "${theme.base0A}";
      };
      normal = {
        black = "${theme.base01}";
        blue = "${theme.base0D}";
        cyan = "${theme.base0C}";
        green = "${theme.base0B}";
        magenta = "${theme.base0E}";
        red = "${theme.base08}";
        white = "${theme.base05}";
        yellow = "${theme.base0A}";
      };
    };
  };
in {
  dark = colors;
  light = colors;
}
