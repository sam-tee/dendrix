{
  flake.modules.nixos.cosmic = _: {
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
