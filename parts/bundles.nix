{inputs, ...}: let
  dMod = inputs.self.modules.darwin;
  hMod = inputs.self.modules.homeManager;
  nMod = inputs.self.modules.nixos;
in {
  flake.modules = {
    nixos = {
      _minimal.imports = with nMod; [
        cli
        networking
        ssh
        system
        user
      ];
      _default.imports = with nMod; [
        _minimal
        boot
        services
        nautilus
      ];
      _mobile.imports = with nMod; [
        _minimal
        services
      ];
      _server.imports = with nMod; [
        _minimal
        boot
        homelab
        anki
        #audiobookshelf
        calibre
        cockpit
        code-server
        email
        forgejo
        immich
        jellyfin
        navidrome
        nextcloud
        nfs
        samba
        #terraria
        vaultwarden
      ];
    };

    darwin._defaul.imports = with dMod; [
      aerospace
      brew
      cli
      networking
      ssh
      system
      user
    ];

    homeManager = {
      _minimal.imports = with hMod; [
        cli
        cosmetic
        fonts
        ghostty
        minPkgs
        ssh
        xournal
        zed
      ];
      _linuxMinimal.imports = with hMod; [
        cliLinux
        cursor
        linuxMinPkgs
        cli
        cosmetic
        fonts
        ghostty
        minPkgs
        ssh
        xournal
        zed
      ];
    };
  };
}
