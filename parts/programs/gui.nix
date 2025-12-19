{
  flake.modules.homeManager = {
    minPkgs = {pkgs, ...}: {
      home.packages = with pkgs; [
        brave
        discord
      ];
    };

    linuxMinPkgs = {pkgs, ...}: {
      home.packages = with pkgs; [
        bitwarden-desktop
        brave
        discord
        protonvpn-gui
      ];
    };

    extraPkgs = {pkgs, ...}: {
      home.packages = with pkgs; [
        gemini-cli
        google-chrome
        spotdl
        yt-dlg
        zotero
      ];
    };

    linuxExtraPkgs = {pkgs, ...}: {
      home.packages = with pkgs; [
        anki
        baobab
        chromium
        gparted
        libreoffice
        protonvpn-gui
        vlc
      ];
    };
  };
}
