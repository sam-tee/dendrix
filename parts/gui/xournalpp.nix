{
  flake.modules.homeManager.xournal = {
    lib,
    pkgs,
    ...
  }: {
    home.packages = lib.mkIf (!pkgs.stdenv.isDarwin) [pkgs.xournalpp];
    xdg.configFile = {
      "xournalpp/palettes/palette.gpl".text = ''
        GIMP Palette
        Name: Sam's Palette
        #
        16 16 16 Black
        255 89 100 Red
        6 214 160 Green
        248 211 83 Yellow
        94 160 252 Blue
        158 114 233 Purple
        248 151 119 Orange
      '';
      "xournalpp/toolbar.ini".text = ''
        [Top]
        name=Top
        toolbarTop1=UNDO,REDO,INSERT_NEW_PAGE,DELETE_CURRENT_PAGE,SEPARATOR,SEPARATOR,PEN,ERASER,IMAGE,TOOL_FILL,HAND,SELECT_OBJECT,SELECT_REGION,FINE,MEDIUM,THICK,SEPARATOR,COLOR(0),COLOR(1),COLOR(2),COLOR(3),COLOR(4),COLOR(5),COLOR(6),COLOR_SELECT,RULER,DRAW
        toolbarBottom1=GOTO_FIRST,GOTO_BACK,PAGE_SPIN,GOTO_NEXT,GOTO_LAST,SEPARATOR,LAYER,SPACER,PAIRED_PAGES,PRESENTATION_MODE,ZOOM_100,ZOOM_FIT,ZOOM_OUT,ZOOM_SLIDER,ZOOM_IN,FULLSCREEN

        [Sides]
        name=Sides
        toolbarLeft1=UNDO,REDO,INSERT_NEW_PAGE,DELETE_CURRENT_PAGE,SEPARATOR,SEPARATOR,PEN,ERASER,IMAGE,TOOL_FILL,HAND,SELECT_OBJECT,SELECT_REGION,FINE,MEDIUM,THICK,SEPARATOR,COLOR(0),COLOR(1),COLOR(2),COLOR(3),COLOR(4),COLOR(5),COLOR(6),COLOR_SELECT,RULER,DRAW
        toolbarRight1=GOTO_FIRST,GOTO_BACK,PAGE_SPIN,GOTO_NEXT,GOTO_LAST,SEPARATOR,SPACER,PAIRED_PAGES,PRESENTATION_MODE,ZOOM_100,ZOOM_FIT,ZOOM_OUT,ZOOM_SLIDER,ZOOM_IN,FULLSCREEN
      '';
    };
  };
}
