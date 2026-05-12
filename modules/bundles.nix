{inputs, ...}: let
  dMod = inputs.self.modules.darwin;
  hMod = inputs.self.modules.homeManager;
  nMod = inputs.self.modules.nixos;
in {
  flake.modules = {
    nixos = {
      _minimal.imports = with nMod; [
        cli
        fonts
        networking
        nixvim
        ssh
        system
        user
      ];
      _default.imports = with nMod; [
        _minimal
        boot
        services
      ];
      _mobile.imports = with nMod; [
        _minimal
        services
      ];
      _serverMin.imports = with nMod; [
        _minimal
        boot
        email
        homelab
      ];
      _serverFull.imports = with nMod; [
        _serverMin
        anki
        arr
        audiobookshelf
        calibre
        cockpit
        code-server
        copyparty
        forgejo
        immich
        jellyfin
        navidrome
        nextcloud
        nfs
        samba
        terraria
        vaultwarden
      ];
    };

    darwin._default.imports = with dMod; [
      brew
      cli
      networking
      nixvim
      ssh
      system
      user
    ];

    homeManager = {
      _minimal.imports = with hMod; [
        cli
        fonts
        nixvim
        sops
        ssh
      ];
      _darwinMinimal.imports = with hMod; [
        _minimal
        ghostty
        minPkgs
        zed
      ];
      _linuxMinimal.imports = with hMod; [
        _minimal
        cliLinux
        ghostty
        gtk
        linuxMinPkgs
        pointer
        xournal
        zed
      ];
    };
  };
}
