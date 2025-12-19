{
  flake.modules.nixos = {
    minimal = {inputs, ...}: {
      imports = with inputs.self.modules.nixos; [
        boot
        cli
        networking
        ssh
        system
        user
      ];
    };
    mobile = {inputs, ...}: {
      imports = with inputs.self.modules.nixos; [
        cli
        networking
        ssh
        system
        user
        servies
      ];
    };
    homelab = {inputs, ...}: {
      imports = with inputs.self.modules.nixos; [
        minimal
        homelab
        calibre
      ];
    };
    default = {inputs, ...}: {
      imports = with inputs.self.modules.nixos; [
        minimal
        services
        nautilus
      ];
    };
  };

  flake.modules.darwin.default = {inputs, ...}: {
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
    minimal = {inputs, ...}: {
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

    linuxMinimal = {inputs, ...}: {
      imports = with inputs.self.modules.homeManager; [
        cliLinux
        cursor
        linuxMinPkgs
        minimal
      ];
    };
  };
}
