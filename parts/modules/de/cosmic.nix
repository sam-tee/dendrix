{...}: {
  flake.modules.nixos.cosmic = {
    services.desktopManager.cosmic = {
      enable = true;
      xwayland.enable = true;
    };
    services.system76-scheduler.enable = true;
    services.displayManager.cosmic-greeter.enable = true;
  };
}
