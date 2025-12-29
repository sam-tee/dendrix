{
  flake.modules.nixos = {
    _minimal = {inputs, ...}: {
      imports = with inputs.self.modules.nixos; [
        cli
        networking
        ssh
        system
        user
      ];
    };
    _mobile = {inputs, ...}: {
      imports = with inputs.self.modules.nixos; [
        _minimal
        services
      ];
    };
    _server = {inputs, ...}: {
      imports = with inputs.self.modules.nixos; [
        _minimal
        boot
        homelab
        anki
        audiobookshelf
        calibre
        cockpit
        code-server
        gitea
        immich
        microbin
        navidrome
        nextcloud
        samba
        terraria
        vaultwarden
      ];
    };
    _default = {inputs, ...}: {
      imports = with inputs.self.modules.nixos; [
        _minimal
        boot
        services
        nautilus
      ];
    };
  };

  flake.modules.darwin._default = {inputs, ...}: {
    imports = with inputs.self.modules.darwin; [
      aerospace
      brew
      cli
      networking
      ssh
      system
      user
    ];
  };

  flake.modules.homeManager = {
    _minimal = {inputs, ...}: {
      imports = with inputs.self.modules.homeManager; [
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

    _linuxMinimal = {inputs, ...}: {
      imports = with inputs.self.modules.homeManager; [
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
