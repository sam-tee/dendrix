{self, ...}: let
  inherit (self.cosmetic) fonts theme;
in {
  flake.modules.homeManager.ghostty = _: {
    programs.ghostty = {
      enable = true;
      settings = {
        font-family = [fonts.mono.name];
        font-size = fonts.size;
        theme = theme.attrs.name;
        window-decoration = "auto";
        unfocused-split-opacity = 0.75;
        shell-integration-features = "ssh-env";
        keybind = [
          "ctrl+shift+w=close_surface"
        ];
      };
      themes.${theme.attrs.name} = {
        background = "${theme.noHash.base00}";
        background-opacity = 1.0;
        foreground = "${theme.noHash.base05}";
        cursor-color = "${theme.noHash.base05}";
        selection-background = "${theme.noHash.base02}";
        selection-foreground = "${theme.noHash.base05}";
        palette = [
          "0=${theme.attrs.base00}"
          "1=${theme.attrs.base08}"
          "2=${theme.attrs.base0B}"
          "3=${theme.attrs.base0A}"
          "4=${theme.attrs.base0D}"
          "5=${theme.attrs.base0E}"
          "6=${theme.attrs.base0C}"
          "7=${theme.attrs.base05}"
          "8=${theme.attrs.base03}"
          "9=${theme.attrs.base08}"
          "10=${theme.attrs.base0B}"
          "11=${theme.attrs.base0A}"
          "12=${theme.attrs.base0D}"
          "13=${theme.attrs.base0E}"
          "14=${theme.attrs.base0C}"
          "15=#ffffff"
        ];
      };
    };
  };
}
