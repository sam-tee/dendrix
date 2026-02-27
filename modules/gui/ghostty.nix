{
  flake.modules.homeManager.ghostty = _: {
    programs.ghostty = {
      enable = true;
      settings = {
        window-decoration = "auto";
        unfocused-split-opacity = 0.75;
        keybind = [
          "ctrl+shift+w=close_surface"
        ];
      };
    };
  };
}
