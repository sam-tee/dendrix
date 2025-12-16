{
  flake.modules.home.xournal = {pkgs, ...}:{
    home.packages = [pkgs.xournalpp];
    home.file = {
      ".config/xournalpp/palette.gpl".source = ./palette.gpl;
      ".config/xournalpp/toolbar.ini".source = ./toolbar.ini;
    };
  };
}
