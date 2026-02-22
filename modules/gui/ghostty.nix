{
  flake.modules.homeManager.ghostty = _: {
    programs.ghostty = {
      enable = true;
      settings = {
        font-size = 14;
        window-decoration = "auto";
        window-theme = "ghostty";
        unfocused-split-opacity = 0.75;
        keybind = [
          "ctrl+shift+w=close_surface"
        ];
        config-file = "?user-config";
      };
    };
  };
}
