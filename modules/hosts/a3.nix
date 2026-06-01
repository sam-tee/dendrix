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
      "${hostname}Config" = {
        config,
        pkgs,
        ...
      }: {
        imports = with self.modules.nixos; [
          _default
          hm
          a3Hardware
          hyprland
          jovian
          mullvad
          steam
          vms
        ];
        home-manager.sharedModules = with self.modules.homeManager; [
          _linuxMinimal
          linuxExtraPkgs
          syncthing
          vscode
          {wayland.windowManager.hyprland.settings.monitor = ["HDMI-A-3,3840x2160@60,auto,1"];}
        ];
        environment.systemPackages = with pkgs; [ffmpeg-full handbrake nautilus];
        programs = {
          virt-manager.enable = true;
          dconf.enable = true;
        };
        users.users.sam.extraGroups = ["libvirtd"];
        networking.interfaces.enp4s0.wakeOnLan.enable = true;
        sops.secrets."wifiHouse.env" = {};
        networking.networkmanager.ensureProfiles = {
          environmentFiles = [config.sops.secrets."wifiHouse.env".path];
          profiles = {
            homeWifi = {
              connection = {
                id = "homeWifi";
                type = "wifi";
                autoconnect = true;
                autoconnect-priority = 100;
              };
              wifi = {
                ssid = "House";
                mode = "infrastructure";
              };
              ipv4 = {
                route-metric = 100;
                method = "auto";
              };
            };
            fallbackEth = {
              connection = {
                id = "fallbackEth";
                type = "ethernet";
                autoconnect = true;
                autoconnect-priority = 0;
                interface-name = "enp4s0";
              };
              ethernet = {};
              ipv4 = {
                method = "auto";
                route-metric = 600;
              };
            };
          };
        };
        hardware.graphics.extraPackages = with pkgs; [
          intel-compute-runtime
          intel-media-driver
          intel-graphics-compiler
          vpl-gpu-rt
          level-zero
        ];
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
