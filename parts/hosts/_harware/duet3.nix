{pkgs, ...}: {
  hardware.firmware = [pkgs.chromeos-sc7180-unredistributable-firmware];
  hardware.sensor.iio.enable = false;
  swapDevices = [
    {
      device = "/swapfile";
      size = 4 * 1024;
    }
  ];
}
