{
  flake.modules.homeManager.pointer = {pkgs, ...}: {
    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.afterglow-cursors-recolored;
      name = "Afterglow-Recolored-Catppuccin-Macchiato";
      size = 24;
    };
  };
}
