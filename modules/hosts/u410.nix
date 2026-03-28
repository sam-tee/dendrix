{self, ...}: let
  hostname = "u410";
  LIBVA_DRIVER_NAME = "i965";
  driveMount = "/var/lib/drive";
in {
  flake = {
    hosts.${hostname} = {
      username = "sam";
      system = "x86_64-linux";
      pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHfvY3X0prLp/RmlR9OpDN0vJbG0RTQHDT0ZePDKsZJ2";
      syncID = "UTMRHSO-5UGRFRV-6WMVUQR-N4B47H6-3AYB7NI-3YGFPEI-E3U42S3-VLCKWAN";
    };

    nixosConfigurations = self.lib.mkNixos hostname;

    modules.nixos = {
      u410Config = {pkgs, ...}: {
        imports = with self.modules.nixos; [
          _serverMin
          hm
          u410Hardware
          arr
          atuin
          calibre
          cockpit
          code-server
          copyparty
          forgejo
          immich
          jellyfin
          syncthing
          vaultwarden
        ];

        environment = {
          sessionVariables = {inherit LIBVA_DRIVER_NAME;};
          systemPackages = with pkgs; [
            (ffmpeg-full.override {withUnfree = true;})
            spotdl
            yt-dlp
          ];
        };
        hardware.graphics = {
          enable = true;
          extraPackages = with pkgs; [
            intel-ocl
            intel-vaapi-driver
          ];
        };
        homelab = {
          domain = "akhlus.uk";
          tunnel = "9dd0d2e2-bc4d-4f2b-9f5b-9e8f1389e123";
          dataDir = driveMount;
        };
        programs.ssh.startAgent = true;
        security.sudo.wheelNeedsPassword = false;
        services.btrfs.autoScrub = {
          enable = true;
          interval = "monthly";
        };
        systemd.services.jellyfin.environment = {inherit LIBVA_DRIVER_NAME;};
      };

      u410Hardware = {
        config,
        lib,
        modulesPath,
        ...
      }: {
        imports = [(modulesPath + "/installer/scan/not-detected.nix")];
        boot = {
          initrd.availableKernelModules = ["xhci_pci" "ehci_pci" "ata_piix" "usb_storage" "sd_mod"];
          kernelModules = ["kvm-intel"];
        };
        fileSystems = {
          "/" = {
            device = "/dev/disk/by-uuid/689713b3-b949-41d4-b7ca-3cab4cabf47f";
            fsType = "ext4";
          };
          "/boot" = {
            device = "/dev/disk/by-uuid/3BB9-4AC9";
            fsType = "vfat";
            options = ["fmask=0077" "dmask=0077"];
          };
          ${driveMount} = {
            device = "/dev/disk/by-uuid/6608ac85-7a69-4bb0-8169-64dfbf4f7830";
            fsType = "btrfs";
            options = ["subvol=media" "compress=zstd"];
          };
        };
        hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
        swapDevices = [{device = "/dev/disk/by-uuid/b87f930d-667c-45c2-a45b-77e8d1971a12";}];
      };
    };
  };
}
