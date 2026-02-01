{
  flake.modules.homeManager.ghostty = {
    config,
    lib,
    ...
  }: let
    userThemes = config.cosmetic.themes;
    removeHash = hex: lib.removePrefix "#" hex;
    ghosttyThemes = import ./_themes.nix {inherit userThemes removeHash;};
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
      themes = ghosttyThemes;
    };
  };
}
