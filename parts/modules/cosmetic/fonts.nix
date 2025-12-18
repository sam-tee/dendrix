let
  mkFonts = pkgs: (with pkgs; [
      inter
      nerd-fonts.lilex
      noto-fonts-color-emoji
  ]);
  fontconfig = {
    enable = true;
    defaultFonts = {
      serif = ["Inter Variable"];
      sansSerif = ["Inter Variable"];
      monospace = ["Lilex Nerd Font"];
      emoji = ["Noto Color Emoji"];
    };
  };
in {
  flake.modules.nixos.fonts = {pkgs, ...}: {
    fonts = {
      packages = mkFonts pkgs;
      inherit fontconfig;
    };
  };

  flake.modules.darwin.fonts = {pkgs, ...}:{
    fonts.packages = mkFonts pkgs;
  };

  flake.modules.home.fonts = {pkgs, ...}:{
    fonts = {inherit fontconfig;};
    home.packages = mkFonts pkgs;
  };
}
