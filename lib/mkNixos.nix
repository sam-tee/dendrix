{
  lib,
  self,
  ...
}: {
  mkNixosModules = hostname: let
    inherit (self.modules) generic nixos;
    inherit (self.hosts.${hostname}) username system pubKey modules hostType;
    hardwareName = "${hostname}Hardware";
    diskoName = "${hostname}Disko";
  in
    if nixos ? ${hardwareName}
    then
      ([
          {
            networking.hostName = hostname;
            nixpkgs.hostPlatform = lib.mkDefault system;
            users.users.${username}.openssh.authorizedKeys.keys = [pubKey];
            system.stateVersion = "24.05";
          }
          generic.default
          nixos.default
          nixos.boot
          nixos.${hardwareName}
        ]
        ++ map (name: nixos.${name}) modules
        ++ (
          if nixos ? ${hostname}
          then [nixos.${hostname}]
          else builtins.trace "warning: host '${hostname}' defines no 'nixos.${hostname}' module, skipping" []
        )
        ++ (
          if nixos ? ${diskoName}
          then [nixos.${diskoName}]
          else []
        ))
    else throw "host '${hostname}' (hostType '${hostType}') needs a 'flake.modules.nixos.${hardwareName}' hardware module";

  # `lib.nixosSystem` passes this (extended) lib on to NixOS modules.
  mkNixos = hostname: {
    ${hostname} = lib.nixosSystem {
      specialArgs = {
        inherit hostname;
        inherit (self.hosts.${hostname}) username;
      };
      modules = lib.mkNixosModules hostname;
    };
  };
}
