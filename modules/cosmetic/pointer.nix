{self, ...}: let
  inherit (self.cosmetic) cursor;
in {
  flake.modules.homeManager.pointer = {pkgs, ...}: {
    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = cursor.pkgsName pkgs;
      inherit (cursor) name size;
    };
  };
}
