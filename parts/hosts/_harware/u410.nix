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
      availableKernelModules = ["xhci_pci" "ehci_pci" "ata_piix" "usb_storage" "sd_mod"];
      kernelModules = [];
    };
    kernelModules = ["kvm-intel"];
    extraModulePackages = [];
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-ocl
      intel-vaapi-driver
    ];
  };

  homelab.cloudflared.tunnel = "74f00e3d-6f30-493c-b088-ae42a415ba23";
  environment.systemPackages = with pkgs; [
    spotdl
    yt-dlp
  ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/d32aab21-0af6-4186-9a51-5a05ece072c2";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/E072-E752";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };
    "/var/lib/media" = {
      device = "/dev/disk/by-uuid/6608ac85-7a69-4bb0-8169-64dfbf4f7830";
      fsType = "btrfs";
      options = ["subvol=media" "compress=zstd"];
    };
    "/export/media" = {
      device = "/var/lib/media";
      options = ["bind"];
    };
  };
  security.sudo.wheelNeedsPassword = false;
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
  };
  services.nfs.server = {
    exports = ''
      /export       *.scylla-goblin.ts.net(rw,fsid=0,no_subtree_check) 192.168.10.0/24(rw,fsid=0,no_subtree_check)
      /export/media *.scylla-goblin.ts.net(rw,nohide,insecure,no_subtree_check) 192.168.10.0/24(rw,nohide,insecure,no_subtree_check)
    '';
  };

  swapDevices = [];
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
