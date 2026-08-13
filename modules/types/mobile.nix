{
  inputs,
  self,
  ...
}: {
  flake-file.inputs.mobile-nixos = {
    url = "github:mobile-nixos/mobile-nixos";
    flake = false;
  };
  flake.lib.mkMobile = hostname: let
    inherit (self.hosts.${hostname}) username system pubKey;
  in {
    ${hostname} = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {inherit hostname username;};
      modules = with self.modules; [
        generic.default
        nixos.${hostname}
        nixos.mobile
        nixos.default
        (import "${inputs.mobile-nixos}/lib/configuration.nix" {device = system;})
        {
          networking.hostName = hostname;
          users.users.${username}.openssh.authorizedKeys.keys = [pubKey];
          system.stateVersion = "24.05";
        }
      ];
    };
  };
  flake.modules.nixos.mobile = {
    config,
    lib,
    ...
  }: {
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
  };
}
