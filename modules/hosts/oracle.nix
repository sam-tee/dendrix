{self, ...}: let
  hostname = "oracle";
in {
  flake = {
    hosts.${hostname} = {
      username = "sam";
      system = "aarch64-linux";
      hostType = "nixos";
      pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILyO7UE5sJmZcNOvsPW148NkH4tk5SefBU32Z66+KWqH";
      syncID = "D4AMT2I-LC25UJA-TONYLR3-I4NLPMP-GYBVM2O-TMTAKC6-I5FE3UE-QG7SSQ3";
    };

    nixosConfigurations = self.lib.mkNixos hostname;

    modules.nixos = {
      ${hostname} = _: {
        imports = with self.modules.nixos; [
          server
          oracleHardware
          oracleDisko
          immich
        ];
        homelab.domain = "akhlus.uk";
        services.immich.database = {
          user = "media";
          name = "media";
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
