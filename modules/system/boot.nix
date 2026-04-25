{
  flake.modules.nixos.boot = {
    lib,
    pkgs,
    ...
  }: {
    boot = {
      binfmt.emulatedSystems = ["aarch64-linux" "x86_64-windows"];
      consoleLogLevel = 0;
      initrd = {
        systemd.enable = true;
        verbose = false;
      };
      kernelPackages = pkgs.linuxPackages_latest;
      kernelParams = [
        "splash"
        "quiet"
        "boot.shell_on_fail"
        "rd.systemd.show_status=false"
        "rd.udev.log_level=3"
        "udev.log_priority=3"
      ];
      loader = {
        systemd-boot = {
          enable = true;
          configurationLimit = 5;
        };
        efi.canTouchEfiVariables = true;
        timeout = lib.mkForce 0;
      };
      plymouth.enable = true;
      supportedFilesystems = ["btrfs" "nfs"];
    };
  };
}
