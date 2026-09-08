{self, ...}: let
  hostname = "a3";
in {
  flake = {
    hosts.${hostname} = {
      username = "sam";
      system = "x86_64-linux";
      hostType = "nixos";
      pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPg6t5m8Ib8Fn+tR4lxJOsi/oKXp6uRSmaX0sfNBmLkU";
      syncID = "M7NGXTT-V47I3WQ-63BVVY3-I3TDBCF-T6YZNVP-KBT5JRC-2K6G7OZ-QBWEHAT";
      tailscaleIP = "100.83.250.118";
    };

    nixosConfigurations = self.lib.mkNixos hostname;

    modules.nixos = {
      ${hostname} = {
        lib,
        pkgs,
        ...
      }: {
        imports = with self.modules.nixos; [
          a3Hardware
          hyprland
          #jovian
          autologin
          linuxAll
          steam
          vms
        ];
        services.gvfs.enable = true;
        services.udev.packages = with pkgs; [libmtp];
        environment.systemPackages = with pkgs; [
          libmtp
          simple-mtpfs
          gvfs
          nautilus
        ];
        networking.interfaces.enp4s0.wakeOnLan.enable = true;
        hardware.graphics.extraPackages = with pkgs; [
          intel-compute-runtime
          intel-media-driver
          intel-graphics-compiler
          vpl-gpu-rt
          level-zero
        ];
        hjem.extraModules = lib.singleton {
          xdg.config.files."hypr/hyprland.lua".text = ''
            hl.monitor({output="HDMI-A-3", scale=2, mode="3840x2160@60.00Hz"})
          '';
        };
      };

      "${hostname}Hardware" = {
        config,
        lib,
        modulesPath,
        ...
      }: {
        imports = [(modulesPath + "/installer/scan/not-detected.nix")];
        boot.initrd = {
          availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
          luks.devices = {
            "luksRoot".device = "/dev/disk/by-uuid/e9a7557e-5a21-4867-b89f-fcbedddc91ff";
            "luksSwap".device = "/dev/disk/by-uuid/f83d2bd7-bce7-41a9-a319-dc192f1a2d8d";
          };
        };
        boot.kernelModules = ["kvm-amd" "rtw88_8821au" "uinput"];
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
          "/mnt/320" = {
            device = "/dev/disk/by-uuid/7fe30e78-6b4b-4364-aff6-bdcac4befc3d";
            fsType = "xfs";
            options = ["defaults" "nofail"];
          };
        };
        swapDevices = [{device = "/dev/mapper/luksSwap";}];
        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
        hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
        hardware.enableRedistributableFirmware = true;
      };
    };
  };
}
