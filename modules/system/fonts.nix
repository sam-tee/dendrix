{self, ...}: let
  inherit (self.cosmetic.fonts) ui mono;
  mkFonts = pkgs: (with pkgs; [
    (mono.pkgsName pkgs)
    (ui.pkgsName pkgs)
    noto-fonts-color-emoji
    noto-fonts-cjk-sans
  ]);
in {
  flake.modules = {
    nixos = {
      default = self.modules.nixos.fonts;
      fonts = {pkgs, ...}: {
        fonts = {
          packages = mkFonts pkgs;
          fontconfig = {
            enable = true;
            defaultFonts = {
              serif = [ui.name];
              sansSerif = [ui.name];
              monospace = [mono.name];
              emoji = ["Noto Color Emoji"];
            };
          };
        };
      };
    };

    darwin.default = {pkgs, ...}: {
      fonts.packages = mkFonts pkgs;
    };
  };
}
