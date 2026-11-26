{
  inputs,
  self,
  ...
}: {
  flake.modules.darwin = {
    default = self.modules.darwin.mac-utils;
    mac-utils = {
      imports = [inputs.mac-utils.darwinModules.default];
      services.mac-utils = {
        enable = true;
        settings = {
          # Pinned to the shortcut carried over from Maccy rather than relying
          # on upstream's default staying the same.
          hotkeys.clipboard = "ctrl+shift+v";
          clipboard.search_mode = "fuzzy";
        };
      };
    };
  };
}
