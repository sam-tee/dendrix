{
  config,
  lib,
  ...
}: let
  inherit (config.cosmetic) fonts theme;
  userTheme = theme.attrs;
  removeHash = hex: lib.removePrefix "#" hex;
in {
  flake.modules.homeManager.ghostty = _: {
    programs.ghostty = {
      enable = true;
      settings = {
        font-family = [fonts.mono.name];
        font-size = fonts.size;
        theme = userTheme.name;
        window-decoration = "auto";
        unfocused-split-opacity = 0.75;
        shell-integration-features = "ssh-terminfo";
        keybind = [
          "ctrl+shift+w=close_surface"
        ];
      };
      themes.${userTheme.name} = {
        background = "${removeHash userTheme.base00}";
        background-opacity = 1.0;
        foreground = "${removeHash userTheme.base05}";
        cursor-color = "${removeHash userTheme.base05}";
        selection-background = "${removeHash userTheme.base02}";
        selection-foreground = "${removeHash userTheme.base05}";
        palette = [
          "0=${userTheme.base01}"
          "1=${userTheme.base08}"
          "2=${userTheme.base0B}"
          "3=${userTheme.base0A}"
          "4=${userTheme.base0D}"
          "5=${userTheme.base0E}"
          "6=${userTheme.base0C}"
          "7=${userTheme.base05}"
          "8=${userTheme.base03}"
          "9=${userTheme.base08}"
          "10=${userTheme.base0B}"
          "11=${userTheme.base0A}"
          "12=${userTheme.base0D}"
          "13=${userTheme.base0E}"
          "14=${userTheme.base0C}"
          "15=${userTheme.base07}"
        ];
      };
    };
  };
}
