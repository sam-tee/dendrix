{self, ...}: let
  hostname = "hp";
in {
  flake = {
    hosts.${hostname} = {
      username = "sam";
      system = "x86_64-linux";
      hostType = "nixos";
      pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIADGGLpndCsctBNb2X8bpEHYHFpL3ew9RI5r18FhK8tc";
      syncID = "V5FOBLK-LGM5BYD-GC4C7TJ-Y5DGLSF-HWPCROU-W27V44I-ICJPM7Q-Y5IZ7A4";
      tailscaleIP = "100.119.213.11";
    };

    nixosConfigurations = self.lib.mkNixos hostname;

    modules.nixos = {
      ${hostname} = {pkgs, ...}: {
        imports = with self.modules.nixos; [
          server
          hpHardware
          hpDisko
          battery
        ];
        environment.systemPackages = with pkgs; [
          ffmpeg-headless
          uv
        ];
        hardware.graphics = {
          enable = true;
          extraPackages = with pkgs; [
            intel-media-driver
            intel-ocl
          ];
        };
        services.btrfs.autoScrub = {
          enable = true;
          interval = "monthly";
        };
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
