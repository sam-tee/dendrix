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
        "luksRoot".device = "/dev/disk/by-uuid/df750502-9fb8-4770-b8ac-e496d1748e20";
        "luksSwap".device = "/dev/disk/by-uuid/c4ebfd35-33b5-4ccb-8678-e430f35a107b";
      };
    };
    kernelModules = ["kvm-amd"];
  };

  fileSystems = {
    "/" = {
      device = "/dev/mapper/luksRoot";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/957F-1A3A";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };
  };
  swapDevices = [{device = "/dev/mapper/luksSwap";}];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
