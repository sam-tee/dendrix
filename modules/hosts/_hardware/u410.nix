{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
  LIBVA_DRIVER_NAME = "i965";
in {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];
  boot = {
    initrd.availableKernelModules = ["xhci_pci" "ehci_pci" "ata_piix" "usb_storage" "sd_mod"];
    kernelModules = ["kvm-intel"];
  };
  environment = {
    sessionVariables = {inherit LIBVA_DRIVER_NAME;};
    systemPackages = with pkgs; [
      spotdl
      yt-dlp
    ];
  };
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/689713b3-b949-41d4-b7ca-3cab4cabf47f";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/3BB9-4AC9";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };
    "/var/lib/media" = {
      device = "/dev/disk/by-uuid/6608ac85-7a69-4bb0-8169-64dfbf4f7830";
      fsType = "btrfs";
      options = ["subvol=media" "compress=zstd"];
    };
  };
  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-ocl
        intel-vaapi-driver
      ];
    };
  };
  homelab = {
    domain = "akhlus.uk";
    tunnel = "9dd0d2e2-bc4d-4f2b-9f5b-9e8f1389e123";
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  security.sudo.wheelNeedsPassword = false;
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
  };
  swapDevices = [{device = "/dev/disk/by-uuid/b87f930d-667c-45c2-a45b-77e8d1971a12";}];
  systemd.services.jellyfin.environment = {inherit LIBVA_DRIVER_NAME;};
}
