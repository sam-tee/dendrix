{
  flake.modules.nixos.boot = {
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkDefault mkForce;
  in {
    boot = {
      consoleLogLevel = mkDefault 0;
      initrd.systemd.network.wait-online.enable = false;
      kernelPackages = pkgs.linuxPackages_latest;
      kernelParams = [
        "splash"
        "quiet"
        "boot.shell_on_fail"
        "rd.systemd.show_status=false"
        "rd.udev.log_level=3"
        "udev.log_priority=3"
        "plymouth.use-simpledrm"
      ];
      loader = {
        systemd-boot = {
          enable = true;
          configurationLimit = 5;
        };
        efi.canTouchEfiVariables = true;
        timeout = mkForce 0;
      };
      plymouth.enable = true;
      supportedFilesystems = ["btrfs" "nfs" "ntfs" "xfs" "exfat"];
    };
  };
}
