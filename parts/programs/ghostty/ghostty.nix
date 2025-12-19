{
  flake.modules.homeManager.ghostty = {
    config,
    lib,
    ...
  }: let
    theme = config.cosmetic.theme;
    removeHash = hex: lib.removePrefix "#" hex;
  in {
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
      themes = import ./_themes.nix theme removeHash;
    };
  };
}
