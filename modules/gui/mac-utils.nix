{
  inputs,
  self,
  ...
}: {
  flake.modules.darwin = {
    default = self.modules.darwin.mac-utils;
    mac-utils = {
      config,
      lib,
      ...
    }: let
      inherit (lib) concatStringsSep mapAttrs' nameValuePair;
      super = concatStringsSep "-" config.keybinds.super;
    in {
      imports = [inputs.mac-utils.darwinModules.default];
      services.mac-utils = {
        enable = true;
        settings = {
          hotkeys.clipboard = "ctrl-shift-v";
          clipboard.search_mode = "fuzzy";
          caps_lock = {
            enabled = true;
            tap = "escape";
            hold = super;
          };
          keybinds = mapAttrs' (key: nameValuePair "${super}-${key}") {
            enter = "open -a Ghostty";
            e = "open -a Finder";
            b = "open -a Helium";
            t = ''open -a "T3 Code (Beta)"'';
            z = "open -a Zed";
          };
        };
      };
    };
  };
}
