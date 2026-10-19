_: let
  hostname = "s340";
in {
  flake = {
    hosts.${hostname} = {
      username = "sam";
      system = "x86_64-linux";
      hostType = "desktop";
      pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIuHm83l7+Fu0CPrHWCL7tcG//mh4/626QImgUXxJekc";
      syncID = "66HL6IU-7E6U2VI-FRBIVMH-Y4SISPF-RT2WJLW-VQY63Q3-AFSXWSW-JWXSOA7";
      tailscaleIP = "100.100.10.13";
      modules = [
        "calibre"
        "linuxAll"
        "mangowc"
      ];
    };

    modules.nixos = {
      ${hostname} = {lib, ...}: {
        hjem.extraModules = lib.singleton {
          xdg.config.files."mango/config.conf".text = lib.mkAfter ''
            monitor_rule=name:^eDP-1$,width:1920,height:1080,refresh:60,x:0,y:0,scale:1
          '';
        };
      };

      "${hostname}Hardware" = {
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
        hardware = {
          amdgpu.initrd.enable = true;
          cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
        };
      };
      "${hostname}Disko" = _: {
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
