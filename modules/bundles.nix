{
  inputs,
  lib,
  self,
  ...
}: let
  dMod = self.modules.darwin;
  hMod = self.modules.homeManager;
  nMod = self.modules.nixos;
in {
  flake.modules = {
    nixos = {
      _minimal.imports = with nMod; [
        cli
        disko
        fonts
        networking
        nixvim
        ssh
        system
        user
      ];
      _default.imports = with nMod; [
        _minimal
        boot
        services
      ];
      _mobile.imports = with nMod; [
        _minimal
        services
        ({config, ...}: {
          hardware.deviceTree.enable = lib.mkDefault (config.boot.kernelPackages.kernel.buildDTBs or false);
          nixpkgs.overlays = lib.mkAfter [
            (final: prev: let
              linuxKernelCompat = platform: {
                target =
                  if platform.isx86
                  then "bzImage"
                  else if platform.isAarch32
                  then "zImage"
                  else if platform.isAarch64 || platform.isRiscV
                  then "Image"
                  else if platform.isLoongArch64
                  then "vmlinuz.efi"
                  else "vmlinux";
                DTB = platform.isAarch || platform.isRiscV || platform.isLoongArch64;
              };
              withLinuxKernelCompat = stdenv:
                stdenv
                // {
                  hostPlatform =
                    stdenv.hostPlatform
                    // {
                      linux-kernel = linuxKernelCompat stdenv.hostPlatform;
                    };
                };
            in {
              mobile-nixos =
                prev.mobile-nixos
                // {
                  kernel-builder = final.callPackage "${inputs.mobile-nixos}/overlay/mobile-nixos/kernel/builder.nix" {
                    stdenv = withLinuxKernelCompat final.stdenv;
                  };
                  kernel-builder-clang = final.callPackage "${inputs.mobile-nixos}/overlay/mobile-nixos/kernel/builder.nix" {
                    stdenv = with final; withLinuxKernelCompat (overrideCC stdenv buildPackages.clang);
                  };
                };
            })
          ];
        })
      ];
      _serverMin.imports = with nMod; [
        _minimal
        boot
        email
        homelab
        mkServer
        syncthing
      ];
    };

    darwin._default.imports = with dMod; [
      brew
      cli
      networking
      nixvim
      ssh
      system
      user
    ];

    homeManager = {
      _minimal.imports = with hMod; [
        cli
        fonts
        nixvim
        sops
        ssh
        system
      ];
      _darwinMinimal.imports = with hMod; [
        _minimal
        ghostty
        minPkgs
        zed
      ];
      _linuxMinimal.imports = with hMod; [
        _minimal
        cliLinux
        ghostty
        gtk
        linuxMinPkgs
        pointer
        xournal
        zed
      ];
    };
  };
}
