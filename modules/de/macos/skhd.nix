{
  flake.modules.darwin.skhd = _: {
    services.skhd = {
      enable = true;
      skhdConfig = ''
        ctrl + cmd  - return : open -a Ghostty
        ctrl + cmd  - e      : open -na Ghostty --args -e yazi
        ctrl + cmd  - b      : open -a Helium
        ctrl + cmd  - z      : open -a Zed
      '';
    };
  };
}
