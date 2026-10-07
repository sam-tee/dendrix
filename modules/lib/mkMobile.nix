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
  flake.modules.nixos.mobile = _: {
    hardware.sensor.iio.enable = true;
    zramSwap = {
      enable = true;
      memoryPercent = 100;
      memoryMax = 4 * 1024 * 1024 * 1024;
    };
  };
}
