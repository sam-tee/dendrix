{
  flake.modules.darwin.options = {lib, ...}: let
    inherit (lib) mkOption;
    inherit (lib.types) enum listOf;
  in {
    options.keybinds.super = mkOption {
      type = listOf (enum ["ctrl" "cmd" "alt" "shift"]);
      default = ["ctrl" "cmd"];
      description = ''
        Modifiers that make up the super key: the prefix for window manager and
        app launcher keybinds, and what Caps Lock sends while held.
      '';
    };
  };
}
