{
  flake.modules.darwin.system = {
    lib,
    pkgs,
    ...
  }: {
    environment.systemPackages = [pkgs.maccy];
    system.defaults.CustomUserPreferences."org.p0deje.Maccy" = {
      KeyboardShortcuts_delete = 0;
      KeyboardShortcuts_pin = 0;
      KeyboardShortcuts_popup = lib.strings.toJSON {
        # cmd+ctrl+v to pop up
        carbonKeyCode = 9;
        carbonModifiers = 4352;
      };
      menuIcon = "clipboard";
      popupPosition = "window";
      searchMode = "fuzzy";
    };
  };
}
