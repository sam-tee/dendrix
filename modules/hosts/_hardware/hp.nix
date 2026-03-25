{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot = {
    initrd.availableKernelModules = ["xhci_pci" "vmd" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"];
    kernelModules = ["kvm-intel"];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/2c56f58d-c167-4b62-955a-575e48ede51d";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/F398-9314";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };
  };
  swapDevices = [{device = "/dev/disk/by-uuid/167d6486-1689-442d-b64a-f7ff75e1bce9";}];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
