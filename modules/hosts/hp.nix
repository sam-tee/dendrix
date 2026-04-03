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
      hpConfig = _: {
        imports = with self.modules.nixos; [
          _default
          hm
          hpHardware
          hyprland
        ];
        home-manager.sharedModules = with self.modules.homeManager; [
          _linuxMinimal
          hyprTouch
          linuxExtraPkgs
          syncthing
          {wayland.windowManager.hyprland.settings.monitor = ["eDP-1,1920x1080@60,auto,1"];}
        ];
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
        fileSystems = {
          "/" = {
            device = "/dev/disk/by-uuid/2c56f58d-c167-4b62-955a-575e48ede51d";
            fsType = "ext4";
          };
          "/boot" = {
            device = "/dev/disk/by-uuid/F398-9314";
            fsType = "vfat";
            options = ["fmask=0077" "dmask=0077"];
          };
        };
        swapDevices = [{device = "/dev/disk/by-uuid/167d6486-1689-442d-b64a-f7ff75e1bce9";}];
        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
        hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      };
    };
  };
}
