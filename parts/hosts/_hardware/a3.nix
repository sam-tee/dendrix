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
      availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
      luks.devices = {
        "luksRoot".device = "/dev/disk/by-uuid/e9a7557e-5a21-4867-b89f-fcbedddc91ff";
        "luksSwap".device = "/dev/disk/by-uuid/f83d2bd7-bce7-41a9-a319-dc192f1a2d8d";
      };
    };
    kernelModules = ["kvm-amd"];
  };

  hardware = {
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-compute-runtime
        intel-media-driver
        intel-graphics-compiler
        level-zero
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
      device = "/dev/mapper/luksRoot";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/9ECA-2C6A";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };
    "/home/sam/hardDrive" = {
      device = "/dev/disk/by-uuid/61410c09-7289-4d7d-aff7-b9053bb5224a";
      fsType = "ext4";
    };
    "/mnt/u410" = {
      device = "192.168.10.10:/export/media";
      fsType = "nfs";
      options = ["x-systemd.automount" "noauto" "x-systemd.idle-timeout=60"];
    };
  };

  swapDevices = [{device = "/dev/mapper/luksSwap";}];

  networking.interfaces.enp4s0.wakeOnLan.enable = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
