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
        "luksRoot".device = "/dev/disk/by-uuid/7929a7d8-eb16-4eed-9e16-09d1fb3a2352";
        "luksSwap".device = "/dev/disk/by-uuid/110f6b06-9cb5-49ce-a6db-2a19e0b86689";
      };
    };
    binfmt.emulatedSystems = ["aarch64-linux" "x86_64-windows"];
    kernelModules = ["kvm-amd"];
  };

  fileSystems = {
    "/" = {
      device = "/dev/mapper/luksRoot";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/9377-4F26";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };
  };
  swapDevices = [{device = "/dev/mapper/luksSwap";}];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
