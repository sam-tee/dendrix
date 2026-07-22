{self, ...}: let
  inherit (self.cosmetic) fonts theme;
  inherit (theme) attrs defaultVariant;
in {
  flake.modules.homeManager.ghostty = {
    lib,
    pkgs,
    ...
  }: let
    isLinux = pkgs.stdenv.hostPlatform.isLinux;
  in {
    programs.ghostty = {
      enable = true;
      package =
        if isLinux
        then pkgs.ghostty
        else pkgs.ghostty-bin;
      settings = {
        font-family = [fonts.mono.name];
        font-size =
          if isLinux
          then fonts.size
          else fonts.size * 4 / 3;
        theme = "${attrs.name}-${defaultVariant}";
        scrollback-limit = 100 * 1024 * 1024;
        window-decoration = "auto";
        keybind = [
          "ctrl+shift+w=close_surface"
        ];
        copy-on-select = "clipboard";
      };
      themes = let
        mkTheme = variant: let
          rmHash = lib.removePrefix "#";
        in
          with attrs.${variant}; {
            background-blur = 20;
            background-opacity = (lib.fromHexString attrs.opacity) * 100 / 255 / 100.0;
            background = rmHash base00;
            foreground = rmHash base05;
            cursor-color = rmHash base05;
            selection-background = rmHash base02;
            selection-foreground = rmHash base05;
            palette = [
              "0=${base00}"
              "1=${base08}"
              "2=${base0B}"
              "3=${base0A}"
              "4=${base0D}"
              "5=${base0E}"
              "6=${base0C}"
              "7=${base05}"
              "8=${base03}"
              "9=${base08}"
              "10=${base0B}"
              "11=${base0A}"
              "12=${base0D}"
              "13=${base0E}"
              "14=${base0C}"
              "15=${base07}"
            ];
          };
      in {
        "${attrs.name}-dark" = mkTheme "dark";
        "${attrs.name}-light" = mkTheme "light";
      };
    };
  };
}
