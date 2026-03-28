{self, ...}: let
  hostname = "s340";
in {
  flake = {
    hosts.${hostname} = {
      username = "sam";
      system = "x86_64-linux";
      pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIuHm83l7+Fu0CPrHWCL7tcG//mh4/626QImgUXxJekc";
      syncID = "7Z2QWJX-7FGBQRR-NTSJKT4-NYXLPX2-PYFARFH-WRAB5NS-DXQU64N-P3FBEAF";
    };

    nixosConfigurations = self.lib.mkNixos hostname;

    modules.nixos = {
      s340Config = {pkgs, ...}: {
        imports = with self.modules.nixos; [
          _default
          hm
          s340Hardware
          autologin
          hyprland
        ];
        home-manager = {
          sharedModules = with self.modules.homeManager; [
            _linuxMinimal
            linuxExtraPkgs
            {
              wayland.windowManager.hyprland.settings.monitor = ["eDP-1,1920x1080@60,auto,1"];
            }
          ];
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
          initrd = {
            availableKernelModules = ["nvme" "xhci_pci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"];
            luks.devices = {
              "luksRoot".device = "/dev/disk/by-uuid/7929a7d8-eb16-4eed-9e16-09d1fb3a2352";
              "luksSwap".device = "/dev/disk/by-uuid/110f6b06-9cb5-49ce-a6db-2a19e0b86689";
            };
          };
          binfmt.emulatedSystems = ["aarch64-linux" "x86_64-windows"];
          kernelModules = ["kvm-amd"];
        };
        fileSystems = {
          "/" = {
            device = "/dev/mapper/luksRoot";
            fsType = "ext4";
          };
          "/boot" = {
            device = "/dev/disk/by-uuid/9377-4F26";
            fsType = "vfat";
            options = ["fmask=0077" "dmask=0077"];
          };
        };
        swapDevices = [{device = "/dev/mapper/luksSwap";}];
        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
        hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      };
    };
  };
}
