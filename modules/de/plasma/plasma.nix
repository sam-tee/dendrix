{
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
    plasmaHM = {inputs, ...}: {
      imports = with inputs.self.modules.nixos; [
        hm
        plasma
        sddm
      ];
      home-manager.sharedModules = [inputs.self.modules.homeManager.plasma];
    };
  };
}
