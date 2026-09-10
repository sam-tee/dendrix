{self, ...}: let
  hostname = "s340";
in {
  flake = {
    hosts.${hostname} = {
      username = "sam";
      system = "x86_64-linux";
      hostType = "nixos";
      pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIuHm83l7+Fu0CPrHWCL7tcG//mh4/626QImgUXxJekc";
      syncID = "66HL6IU-7E6U2VI-FRBIVMH-Y4SISPF-RT2WJLW-VQY63Q3-AFSXWSW-JWXSOA7";
      tailscaleIP = "100.100.10.13";
    };

    nixosConfigurations = self.lib.mkNixos hostname;

    modules.nixos = {
      ${hostname} = {
        lib,
        pkgs,
        ...
      }: {
        imports = with self.modules.nixos; [
          s340Hardware
          s340Disko
          niri
        ];
        hjem.extraModules = lib.singleton {
          xdg.config.files."niri/config.kdl".text = lib.mkAfter ''
            output "eDP-1" {
              mode "1920x1080"
              scale 1.0
            }
          '';
        };
        services.usbmuxd.enable = true;
        environment.systemPackages = with pkgs; [calibre];
      };

      s340Hardware = {
        config,
        lib,
        modulesPath,
        ...
      }: {
        imports = [(modulesPath + "/installer/scan/not-detected.nix")];
        boot = {
          initrd.availableKernelModules = ["nvme" "xhci_pci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"];
          binfmt.emulatedSystems = ["aarch64-linux" "x86_64-windows"];
          kernelModules = ["kvm-amd"];
        };
        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
        hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      };
      s340Disko = _: {
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
