{
  flake.modules.homeManager.skhd = _: {
    services.skhd = {
      enable = true;
      config = ''
        ctrl + cmd - return : open -a Ghostty
        ctrl + cmd - e      : open -a Finder
        ctrl + cmd - b      : open -a Helium
        ctrl + cmd - z      : open -a Zed
      '';
    };
  };
}
