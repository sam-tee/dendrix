{
  inputs,
  self,
  ...
}: let
  inherit (self.modules) generic nixos;
in {
  flake.lib.mkMobile = hostname: let
    inherit (self.hosts.${hostname}) username system pubKey modules;
  in {
    ${hostname} = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {inherit hostname username;};
      modules =
        [
          generic.default
        ]
        ++ map (name: nixos.${name}) modules
        ++ (
          if nixos ? ${hostname}
          then [nixos.${hostname}]
          else builtins.trace "warning: host '${hostname}' defines no 'nixos.${hostname}' module, skipping" []
        )
        ++ [
          nixos.mobile
          nixos.default
          inputs.mobile-nixos.nixosModules.${system}
          {
            networking.hostName = hostname;
            users.users.${username}.openssh.authorizedKeys.keys = [pubKey];
            system.stateVersion = "24.05";
          }
        ];
    };
  };
  flake.modules.nixos.mobile = {config, ...}: {
    hardware.sensor.iio.enable = true;
    zramSwap = {
      enable = true;
      memoryPercent = 100;
      memoryMax = 4 * 1024 * 1024 * 1024;
    };
    system.activationScripts.mobileKernelCheck.text = let
      expected = config.boot.kernelPackages.kernel.modDirVersion;
      device = config.mobile.device.name;
      mobileRev = inputs.mobile-nixos.rev or "unknown";
    in ''
      running="$(uname -r)"
      if [ "$running" != "${expected}" ]; then
        echo "WARNING: running kernel '$running' does not match this system ('${expected}')." >&2
        echo "WARNING: wifi, input, audio and battery drivers will fail after reboot until KPART is reflashed:" >&2
        echo "WARNING:   nix-build --argstr device ${device} -A outputs.kpart <mobile-nixos@${mobileRev}>" >&2
        echo "WARNING:   dd if=result/bin/system/*/kpart-* of=/dev/disk/by-partlabel/KERNEL-A bs=8M oflag=sync,direct status=progress" >&2
      fi
    '';
  };
}
