{self, ...}: let
  hostname = "prometheus";
in {
  flake = {
    hosts.${hostname} = {
      username = "sam";
      system = "x86_64-linux";
      pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIADGGLpndCsctBNb2X8bpEHYHFpL3ew9RI5r18FhK8tc";
    };
    nixosConfigurations = self.lib.mkNixos hostname;
    modules.nixos = {
      prometheusConfig = _: {
        imports = with self.modules.nixos; [
          self.inputs.disko.nixosModules.disko
          prometheusHardware
          prometheusDisko
          ssh
        ];
        boot.loader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
        };
        users.users.sam = {
          isNormalUser = true;
          extraGroups = ["networkmanager" "wheel"];
          initialPassword = "temp";
        };
        networking.networkmanager.enable = true;
        services.tailscale.enable = true;
        programs = {
          bat.enable = true;
          git.enable = true;
          lazygit.enable = true;
          nh.enable = true;
          ssh.startAgent = true;
          zoxide.enable = true;
        };
        nix.settings = {
          use-xdg-base-directories = true;
          keep-going = true;
          experimental-features = [
            "nix-command"
            "flakes"
            "auto-allocate-uids"
            "pipe-operators"
          ];
          trusted-users = [
            "@admin"
            "@wheel"
            "sam"
          ];
        };
        nixpkgs.config.allowUnfree = true;
      };
      prometheusHardware = {
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
      prometheusDisko = _: {
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
