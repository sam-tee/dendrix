_: {
  flake.modules.nixos.mobile = {
    hardware.sensor.iio.enable = true;
    zramSwap = {
      enable = true;
      memoryPercent = 100;
      memoryMax = 4 * 1024 * 1024 * 1024;
    };
  };
}
