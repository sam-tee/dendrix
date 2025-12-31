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
      monospace = ["Lilex Nerd Font Propo"];
      emoji = ["Noto Color Emoji"];
    };
  };
in {
  flake.modules.nixos.system = {pkgs, ...}: {
    fonts = {
      packages = mkFonts pkgs;
      inherit fontconfig;
    };
  };

  flake.modules.darwin.system = {pkgs, ...}: {
    fonts.packages = mkFonts pkgs;
  };

  flake.modules.homeManager.fonts = {pkgs, ...}: {
    fonts = {inherit fontconfig;};
    home.packages = mkFonts pkgs;
  };
}
