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
        (with pkgs; [
          brave
          localsend
        ])
        ++ lib.optionals (pkgs.stdenv.hostPlatform.system == "x86_64-linux") (with pkgs; [discord]);
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
          proton-vpn
        ])
        ++ lib.optionals (isNotAarchLinux pkgs) (with pkgs; [
          discord
          spotify
        ]);
    };

    extraPkgs = {pkgs, ...}: {
      home.packages = with pkgs; [
        zotero
      ];
    };

    linuxExtraPkgs = {pkgs, ...}: {
      home.packages = with pkgs; [
        anki
        baobab
        chromium
        gparted
        haruna
        libreoffice
        proton-vpn
        vlc
      ];
    };
  };
}
