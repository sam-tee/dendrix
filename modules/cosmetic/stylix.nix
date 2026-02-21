{config, ...}: {
  flake-file.inputs.stylix = {
    url = "github:nix-community/stylix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake.modules = let
    mkFont = name: package: {
      inherit name package;
    };
    mkFonts = pkgs: {
      emoji = mkFont "Noto Color Emoji" pkgs.noto-fonts-color-emoji;
      monospace = mkFont "Lilex Nerd Font Propo" pkgs.nerd-fonts.lilex;
      sansSerif = mkFont "Inter Variable" pkgs.inter;
      serif = mkFont "Inter Variable" pkgs.inter;
    };
  in {
    nixos.stylix = {
      pkgs,
      self,
      ...
    }: {
      imports = [self.inputs.stylix.nixosModules.stylix];
      stylix = {
        enable = true;
        base16Scheme = config.cosmetic.themeFile;
        image = config.cosmetic.backgroundFile;
        autoEnable = true;
        polarity = "dark";
        fonts = mkFonts pkgs;
        cursor = {
          name = "Afterglow-Recolored-Catppuccin-Macchiato";
          package = pkgs.afterglow-cursors-recolored;
          size = 24;
        };
      };
    };
    homeManager.stylix = {
      pkgs,
      self,
      ...
    }: {
      imports = [self.inputs.stylix.homeModules.stylix];
      stylix = {
        enable = true;
        base16Scheme = config.cosmetic.themeFile;
        image = config.cosmetic.backgroundFile;
        autoEnable = true;
        polarity = "dark";
        fonts = mkFonts pkgs;
        targets = {
          zed.enable = false;
        };
      };
    };
  };
}
