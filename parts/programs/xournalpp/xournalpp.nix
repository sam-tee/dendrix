{
  flake.modules.homeManager.xournal = {pkgs, ...}: {
    home.packages = [pkgs.xournalpp];
    xdg.configFile = {
      "xournalpp/palette.gpl".source = ./palette.gpl;
      "xournalpp/toolbar.ini".source = ./toolbar.ini;
    };
  };
}
