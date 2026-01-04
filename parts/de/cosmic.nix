{
  flake.modules.nixos.cosmic = {
    services = {
      desktopManager.cosmic = {
        enable = true;
        xwayland.enable = true;
      };
      system76-scheduler.enable = true;
      displayManager.cosmic-greeter.enable = true;
    };
  };
}
