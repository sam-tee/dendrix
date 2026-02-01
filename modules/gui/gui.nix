{
  flake.modules.homeManager = {
    minPkgs = {pkgs, ...}: {
      home.packages = with pkgs; [
        brave
        discord
      ];
    };

    linuxMinPkgs = {pkgs, ...}: {
      home.sessionVariables.SSH_AUTH_SOCK = "$HOME/.bitwarden-ssh-agent.sock";
      home.packages = with pkgs; [
        bitwarden-desktop
        brave
        discord
        protonvpn-gui
        spotify
      ];
    };

    extraPkgs = {pkgs, ...}: {
      home.packages = with pkgs; [
        gemini-cli
        google-chrome
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
