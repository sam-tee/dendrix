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
      sizes.applications = 10.5;
    };
  in {
    nixos.stylix = {
      pkgs,
      inputs,
      ...
    }: {
      imports = [inputs.stylix.nixosModules.stylix];
      stylix = {
        enable = true;
        base16Scheme = config.cosmetic.theme;
        image = config.cosmetic.backgroundFile;
        autoEnable = true;
        polarity = "dark";
        fonts = mkFonts pkgs;
      };
    };
    homeManager = {
      stylixLinux = {
        inputs,
        pkgs,
        ...
      }: {
        imports = [inputs.self.modules.homeManager.stylix];
        stylix.cursor = {
          name = "Afterglow-Recolored-Catppuccin-Macchiato";
          package = pkgs.afterglow-cursors-recolored;
          size = 24;
        };
      };
      stylix = {
        pkgs,
        inputs,
        ...
      }: {
        imports = [inputs.stylix.homeModules.stylix];
        stylix = {
          enable = true;
          base16Scheme = config.cosmetic.theme;
          image = config.cosmetic.backgroundFile;
          autoEnable = true;
          polarity = "dark";
          fonts = mkFonts pkgs;
          targets.zed.colors.enable = false;
        };
      };
    };
  };
}
