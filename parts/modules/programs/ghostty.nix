{
  flake.modules.home.ghostty = {
    programs.ghostty = {
      enable = true;
      settings = {
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
      themes.akhlus = {
        background = "101010";
        background-opacity = 1.;
        foreground = "e7e7e7";
        cursor-color = "e7e7e7";
        selection-background = "323232";
        selection-foreground = "e7e7e7";
        palette = [
        "0=#161616"
        "1=#ff5964"
        "2=#06d6a0"
        "3=#f8d353"
        "4=#5eb0fc"
        "5=#9e72e9"
        "6=#72e9c5"
        "7=#e7e7e7"
        "8=#454545"
        "9=#ff5964"
        "10=#06d6a0"
        "11=#f8d353"
        "12=#5eb0fc"
        "13=#9e72e9"
        "14=#72e9c5"
        "15=#b4be1e"
        ];
      };
    };
  };
}
