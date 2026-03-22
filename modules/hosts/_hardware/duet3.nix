{
  pkgs,
  username,
  ...
}: {
  hardware.firmware = [pkgs.chromeos-sc7180-unredistributable-firmware];
  swapDevices = [
    {
      device = "/swapfile";
      size = 4 * 1024;
    }
  ];
  home-manager.users.${username} = {
    hypr.monitors = ["DSI-1,2000x1200@60,auto,1,transform,1"];
  };
}
