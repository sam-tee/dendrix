{self, ...}: let
  hostname = "oracle";
in {
  flake = {
    hosts.${hostname} = {
      username = "sam";
      system = "aarch64-linux";
      pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILyO7UE5sJmZcNOvsPW148NkH4tk5SefBU32Z66+KWqH";
      syncID = "";
    };

    nixosConfigurations = self.lib.mkNixos hostname;

    modules.nixos = {
      oracleConfig = _: {
        imports = with self.modules.nixos; [
          _minimal
          boot
          oracleHardware
          oracleDisko
        ];
        security.sudo.wheelNeedsPassword = false;
        nix.settings = {
          max-jobs = 4;
          builders-use-substitutes = true;
        };
      };

      oracleHardware = {
        lib,
        modulesPath,
        ...
      }: {
        imports = [(modulesPath + "/profiles/qemu-guest.nix")];
        boot = {
          initrd.availableKernelModules = ["xhci_pci" "virtio_pci" "virtio_scsi" "usbhid"];
          kernelParams = ["net.ifnames=0"];
        };
        nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
      };

      oracleDisko = _: {
        disko.devices.disk.main = {
          type = "disk";
          device = "/dev/sda";
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
                };
              };
              root = {
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                };
              };
            };
          };
        };
      };
    };
  };
}
