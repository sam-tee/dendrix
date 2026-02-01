{pkgs, ...}: {
  hardware.firmware = [pkgs.chromeos-sc7180-unredistributable-firmware];
  swapDevices = [
    {
      device = "/swapfile";
      size = 4 * 1024;
    }
  ];
}
