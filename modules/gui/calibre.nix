{self, ...}: {
  flake.modules.nixos = {
    linuxAll = self.modules.nixos.calibre;
    calibre = {pkgs, ...}: let
      # piper-tts withTrain pulls torch/librosa/lightning (1h+ closure,
      # broken on aarch64-linux). Calibre only needs inference.
      piper-tts-no-train = pkgs.piper-tts.override {withTrain = false;};
      calibre-fixed = pkgs.calibre.override {piper-tts = piper-tts-no-train;};
    in {
      environment.systemPackages = [calibre-fixed];
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
