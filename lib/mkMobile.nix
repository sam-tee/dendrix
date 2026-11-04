{
  inputs,
  lib,
  self,
  ...
}: {
  mkMobile = hostname: let
    inherit (self.modules) generic nixos;
    inherit (self.hosts.${hostname}) username system pubKey modules;
  in {
    ${hostname} = lib.nixosSystem {
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
}
