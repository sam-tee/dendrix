{
  flake.modules.nixos.battery = _: {
    powerManagement.powertop.enable = true;
    services.tlp = {
      enable = true;
      settings = {
        START_CHARGE_THRESH_BAT1 = 40;
        STOP_CHARGE_THRESH_BAT1 = 50;
        RESTORE_THRESHOLDS_ON_BAT = 1;
      };
    };
  };
}
