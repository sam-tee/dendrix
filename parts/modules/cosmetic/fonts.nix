{pkgs, ...}: let
  fontPackages = with pkgs; [
    inter
    nerd-fonts.lilex
    noto-fonts-color-emoji
  ];
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
  flake.modules.nixos.fonts = {
    fonts = {
      packages = fontPackages;
      inherit fontconfig;
    };
  };

  flake.modules.darwin.fonts.fonts.packages = fontPackages;

  flake.modules.home.fonts = {
    fonts = {inherit fontconfig;};
    home.packages = fontPackages;
  };
}
