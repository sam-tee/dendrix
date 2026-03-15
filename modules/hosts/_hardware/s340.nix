{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}: {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  services.usbmuxd.enable = true;
  environment.systemPackages = with pkgs; [calibre];

  boot = {
    initrd = {
      availableKernelModules = ["nvme" "xhci_pci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"];
      luks.devices = {
        "root".device = "/dev/disk/by-uuid/cd146ce4-d082-4a5d-a277-4083f8f42cea";
        "swap".device = "/dev/disk/by-uuid/0858f521-0528-4836-8a0a-3fed95ad39cc";
      };
    };
    kernelModules = ["kvm-amd"];
  };

  fileSystems = {
    "/" = {
      device = "/dev/mapper/root";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/9B79-5238";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };
  };
  swapDevices = [{device = "/dev/mapper/swap";}];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
