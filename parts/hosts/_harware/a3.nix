{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"];
      kernelModules = [];
      luks.devices = {
        "luks-e9a7557e-5a21-4867-b89f-fcbedddc91ff".device = "/dev/disk/by-uuid/e9a7557e-5a21-4867-b89f-fcbedddc91ff";
        "luks-f83d2bd7-bce7-41a9-a319-dc192f1a2d8d".device = "/dev/disk/by-uuid/f83d2bd7-bce7-41a9-a319-dc192f1a2d8d";
      };
    };
    kernelModules = ["kvm-amd"];
    extraModulePackages = [];
  };

  hardware = {
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-compute-runtime
        intel-media-driver
        intel-graphics-compiler
        level-zero
        clinfo
        vpl-gpu-rt
      ];
    };
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/661f80e0-bbfe-4c57-83c2-24c030f97e70";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/9ECA-2C6A";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };
    "/home/sam/Disks" = {
      device = "/dev/disk/by-uuid/61410c09-7289-4d7d-aff7-b9053bb5224a";
      fsType = "ext4";
    };
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/eddfdb40-e87f-452c-b55c-12790846692f";}
  ];
  networking = {
    useNetworkd = lib.mkDefault true;
    interfaces.enp4s0 = {
      useDHCP = lib.mkDefault true;
      wakeOnLan = lib.mkDefault true;
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
