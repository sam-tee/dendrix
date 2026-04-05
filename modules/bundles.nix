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
      ssh
      system
      user
    ];

    homeManager = {
      _minimal.imports = with hMod; [
        cli
        fonts
        sops
        ssh
        theming
      ];
      _darwinMinimal = {
        programs.ghostty.package = null;
        imports = with hMod; [
          cli
          stylix
          ghostty
          minPkgs
          sops
          ssh
          zed
        ];
      };
      _linuxMinimal.imports = with hMod; [
        cli
        cliLinux
        fonts
        ghostty
        linuxMinPkgs
        pointer
        sops
        ssh
        theming
        xournal
        zed
      ];
    };
  };
}
