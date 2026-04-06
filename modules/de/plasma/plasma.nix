{self, ...}: {
  flake.modules.nixos = {
    plasma = {pkgs, ...}: {
      environment = {
        systemPackages = with pkgs.kdePackages; [
          filelight
          partitionmanager
        ];
        plasma6.excludePackages = with pkgs.kdePackages; [
          discover
          elisa
          gwenview
          kate
          konsole
          plasma-browser-integration
        ];
      };
      services.desktopManager.plasma6.enable = true;
    };
    plasmaHM = _: {
      imports = with self.modules.nixos; [
        hm
        plasma
        sddm
      ];
      home-manager.sharedModules = with self.modules.homeManager; [plasma];
    };
  };
}
