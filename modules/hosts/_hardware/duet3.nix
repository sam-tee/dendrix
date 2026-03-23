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
    hypr.monitors = ["DSI-1,1200x2000@60,0x0,1,transform,1"];
    wayland.windowManager.hyprland.settings.device = [
      {
        name = "hid-over-i2c-0603:604a";
        output = "DSI-1";
        trnsform = 1;
      }
      {
        name = "hid-over-i2c-0603:604a-stylus";
        output = "DSI-1";
        transform = 1;
      }
    ];
  };
}
