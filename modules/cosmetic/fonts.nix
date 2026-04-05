{self, ...}: let
  inherit (self.cosmetic.fonts) ui mono;
  mkFonts = pkgs: (with pkgs; [
    (mono.pkgsName pkgs)
    (ui.pkgsName pkgs)
    noto-fonts-color-emoji
    noto-fonts-cjk-sans
  ]);
  fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [ui.name];
      sansSerif = [ui.name];
      monospace = [mono.name];
      emoji = ["Noto Color Emoji"];
    };
  };
in {
  flake.modules = {
    nixos.fonts = {pkgs, ...}: {
      fonts = {
        packages = mkFonts pkgs;
        inherit fontconfig;
      };
    };

    darwin.fonts = {pkgs, ...}: {
      fonts.packages = mkFonts pkgs;
    };

    homeManager.fonts = {pkgs, ...}: {
      fonts = {inherit fontconfig;};
      home.packages = mkFonts pkgs;
    };
  };
}
