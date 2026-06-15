{self, ...}: let
  hostname = "prometheus";
in {
  flake = {
    hosts.${hostname} = {
      username = "sam";
      system = "x86_64-linux";
      hostType = "nixos";
      pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIuHm83l7+Fu0CPrHWCL7tcG//mh4/626QImgUXxJekc";
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
        system.stateVersion = "24.05";
        xdg.terminal-exec.enable = true;
        services.xserver.xkb = {
          layout = "gb";
          variant = "";
        };
        time.timeZone = "Europe/London";
        console.keyMap = "uk";
        i18n = {
          defaultLocale = "en_GB.UTF-8";
          extraLocaleSettings = {
            LC_ADDRESS = "en_GB.UTF-8";
            LC_IDENTIFICATION = "en_GB.UTF-8";
            LC_MEASUREMENT = "en_GB.UTF-8";
            LC_MONETARY = "en_GB.UTF-8";
            LC_NAME = "en_GB.UTF-8";
            LC_NUMERIC = "en_GB.UTF-8";
            LC_PAPER = "en_GB.UTF-8";
            LC_TELEPHONE = "en_GB.UTF-8";
            LC_TIME = "en_GB.UTF-8";
          };
        };
      };
      prometheusHardware = {
        config,
        lib,
        modulesPath,
        ...
      }: {
        imports = [(modulesPath + "/installer/scan/not-detected.nix")];
        boot = {
          initrd.availableKernelModules = ["nvme" "xhci_pci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"];
          kernelModules = ["kvm-amd"];
        };
        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
        hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
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
