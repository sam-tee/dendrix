{self, ...}: let
  hostname = "a3";
in {
  flake = {
    hosts.${hostname} = {
      username = "sam";
      system = "x86_64-linux";
      pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPg6t5m8Ib8Fn+tR4lxJOsi/oKXp6uRSmaX0sfNBmLkU";
      syncID = "GITF6T5-Q23HCQ6-SBMP3ZC-J77WSL4-BBNHO2U-6C2L2XA-GVJ2FWQ-RERKCQH";
    };

    nixosConfigurations = self.lib.mkNixos hostname;

    modules.nixos = {
      "${hostname}Config" = {pkgs, ...}: {
        imports = with self.modules.nixos; [
          _default
          hm
          a3Hardware
          hyprland
          steam
        ];
        home-manager.sharedModules = with self.modules.homeManager; [
          _linuxMinimal
          linuxExtraPkgs
          syncthing
          vscode
          {wayland.windowManager.hyprland.settings.monitor = ["HDMI-A-3,3840x2160@60,auto,1"];}
        ];
        virtualisation = {
          spiceUSBRedirection.enable = true;
          libvirtd = {
            enable = true;
            qemu.verbatimConfig = ''display_gl = "on"'';
          };
        };
        programs = {
          virt-manager.enable = true;
          dconf.enable = true;
        };
        users.users.sam.extraGroups = ["libvirtd"];
        networking.interfaces.enp4s0.wakeOnLan.enable = true;
        hardware = {
          graphics.extraPackages = with pkgs; [
            intel-compute-runtime
            intel-media-driver
            intel-graphics-compiler
            vpl-gpu-rt
            level-zero
          ];
          bluetooth = {
            enable = true;
            powerOnBoot = true;
          };
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
        boot.kernelModules = ["kvm-amd"];
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
        };
        swapDevices = [{device = "/dev/mapper/luksSwap";}];
        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
        hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      };
    };
  };
}
