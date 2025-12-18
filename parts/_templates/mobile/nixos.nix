{
  pkgs,
  username,
  ...
}: {
  nMods = {
    de = {
      environment = "plasma";
      enableAutoLogin = true;
    };
    boot.enable = false;
    ssh.publicKey = "PUB_KEY";
  };

  hardware = {
    firmware = [
      pkgs.chromeos-sc7180-unredistributable-firmware
    ];
    sensor.iio.enable = true;
  };

  home-manager.users.${username}.imports = [./home.nix];
}
