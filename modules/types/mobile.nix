{
  inputs,
  self,
  ...
}: {
  flake-file.inputs.mobile-nixos.url = "git+https://${self.services.forgejo.fqdn}/sam-tee/mobile.git";

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
        inputs.mobile-nixos.nixosModules.${system}
        {
          networking.hostName = hostname;
          users.users.${username}.openssh.authorizedKeys.keys = [pubKey];
          system.stateVersion = "24.05";
        }
      ];
    };
  };
  flake.modules.nixos.mobile = _: {
    hardware.sensor.iio.enable = true;
    zramSwap = {
      enable = true;
      memoryPercent = 100;
      memoryMax = 4 * 1024 * 1024 * 1024;
    };
  };
}
