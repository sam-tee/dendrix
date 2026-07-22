{
  flake.modules.homeManager.skhd = _: {
    services.skhd = {
      enable = true;
      config = ''
        ctrl + alt + cmd - return : open -na Ghostty
        ctrl + alt + cmd - e      : open -na Ghostty --args -e yazi
        ctrl + alt + cmd - b      : open -a Helium
        ctrl + alt + cmd - z      : open -a Zed
      '';
    };
  };
}
