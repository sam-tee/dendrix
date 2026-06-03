{self, ...}: let
  hostname = "hp";
in {
  flake = {
    hosts.${hostname} = {
      username = "sam";
      system = "x86_64-linux";
      pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIADGGLpndCsctBNb2X8bpEHYHFpL3ew9RI5r18FhK8tc";
      syncID = "DK3XF6A-JKNRNEY-XRRAKHZ-76S4OTX-F25HKP7-YWAA253-SPKMWHL-DNBOJAK";
    };

    nixosConfigurations = self.lib.mkNixos hostname;

    modules.nixos = {
      hpConfig = {pkgs, ...}: {
        imports = with self.modules.nixos; [
          _default
          hm
          hpHardware
          hpDisko
        ];
        home-manager.sharedModules = with self.modules.homeManager; [
          _linuxMinimal
          #hyprTouch
          syncthing
          {
            wayland.windowManager.hyprland.settings = {
              monitor = ["eDP-1,1920x1080@60,auto,1"];
              device = [
                {
                  name = "elan2514:00-04f3:2cf1-stylus";
                  output = "eDP-1";
                }
                {
                  name = "elan2514:00-04f3:2cf1";
                  output = "eDP-1";
                }
              ];
            };
          }
        ];
        environment.systemPackages = [pkgs.calibre];
      };

      hpHardware = {
        config,
        lib,
        modulesPath,
        ...
      }: {
        imports = [(modulesPath + "/installer/scan/not-detected.nix")];
        boot = {
          initrd.availableKernelModules = ["xhci_pci" "vmd" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"];
          kernelModules = ["kvm-intel"];
        };
        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
        hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      };

      hpDisko = _: {
        disko.devices.disk.main = {
          type = "disk";
          device = "/dev/nvme0n1";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                size = "1G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = ["umask=0077"];
                };
              };
              swap = {
                size = "8G";
                content = {
                  type = "swap";
                  randomEncryption = true;
                };
              };
              root = {
                size = "100%";
                content = {
                  type = "btrfs";
                  extraArgs = ["-f"];
                  mountpoint = "/";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
              };
            };
          };
        };
      };
    };
  };
}
