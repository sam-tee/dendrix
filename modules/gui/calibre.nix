{self, ...}: {
  flake.modules.nixos = {
    linuxAll = self.modules.nixos.calibre;
    calibre = {pkgs, ...}: {
      environment.systemPackages = [pkgs.calibre];
      xdg.mime = {
        removedAssociations = {
          "application/xhtml+xml" = ["calibre-ebook-viewer.desktop" "calibre-gui.desktop"];
          "application/pdf" = ["calibre-ebook-viewer.desktop"];
          "text/html" = ["calibre-ebook-viewer.desktop" "calibre-gui.desktop"];
          "text/markdown" = ["calibre-ebook-viewer.desktop" "calibre-gui.desktop"];
          "text/plain" = ["calibre-ebook-viewer.desktop" "calibre-gui.desktop"];
          "text/rtf" = ["calibre-ebook-viewer.desktop" "calibre-gui.desktop"];
          "text/x-markdown" = ["calibre-ebook-viewer.desktop" "calibre-gui.desktop"];
        };
        defaultApplications."application/epub+zip" = "calibre-ebook-viewer.desktop";
      };
    };
  };
}
