{
  flake.modules.homeManager.ghostty = {
    config,
    lib,
    ...
  }: let
    userThemes = config.cosmetic.themes;
    removeHash = hex: lib.removePrefix "#" hex;
  in {
    programs.ghostty = {
      enable = true;
      settings = {
        #command = "~/.nix-profile/bin/tmux";
        font-family = "Lilex Nerd Font";
        font-size = 14;
        window-decoration = "auto";
        window-theme = "ghostty";
        theme = "akhlus";
        unfocused-split-opacity = 0.75;
        keybind = [
          "ctrl+shift+w=close_surface"
          "cmd+shift+w=close_surface"
        ];
        config-file = "?user-config";
      };
      themes = let
        mkTheme = theme: {
          background = "${removeHash theme.base00}";
          background-opacity = 1.0;
          foreground = "${removeHash theme.base05}";
          cursor-color = "${removeHash theme.base05}";
          selection-background = "${removeHash theme.base02}";
          selection-foreground = "${removeHash theme.base05}";
          palette = [
            "0=${theme.base01}"
            "1=${theme.base08}"
            "2=${theme.base0B}"
            "3=${theme.base0A}"
            "4=${theme.base0D}"
            "5=${theme.base0E}"
            "6=${theme.base0C}"
            "7=${theme.base05}"
            "8=${theme.base03}"
            "9=${theme.base08}"
            "10=${theme.base0B}"
            "11=${theme.base0A}"
            "12=${theme.base0D}"
            "13=${theme.base0E}"
            "14=${theme.base0C}"
            "15=${theme.base07}"
          ];
        };
      in
        builtins.listToAttrs (map (theme: {
            inherit (theme) name;
            value = mkTheme theme;
          })
          userThemes);
    };
  };
}
