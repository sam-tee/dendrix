{
  flake.modules.nixos.plasma = {pkgs, ...}: {
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
}
