{
  flake.modules.homeManager = let
    isNotAarchLinux = pkgs: (pkgs.stdenv.hostPlatform.system != "aarch64-linux");
  in {
    minPkgs = {
      lib,
      pkgs,
      ...
    }: {
      home.packages =
        (with pkgs; [brave])
        ++ lib.optionals (isNotAarchLinux pkgs) (with pkgs; [discord]);
    };

    linuxMinPkgs = {
      lib,
      pkgs,
      ...
    }: {
      home.sessionVariables.SSH_AUTH_SOCK = "$HOME/.bitwarden-ssh-agent.sock";
      home.packages =
        (with pkgs; [
          bitwarden-desktop
          brave
          protonvpn-gui
        ])
        ++ lib.optionals (isNotAarchLinux pkgs) (with pkgs; [
          discord
          spotify
        ]);
    };

    extraPkgs = {pkgs, ...}: {
      home.packages = with pkgs; [
        gemini-cli
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
