{inputs, ...}: {
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
