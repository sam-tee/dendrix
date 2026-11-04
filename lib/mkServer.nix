{
  lib,
  self,
  ...
}: let
  inherit (lib) mkNixosModules nixosSystem;
in {
  # Like mkNixos, but also imports the shared headless-server module.
  mkServer = hostname: {
    ${hostname} = nixosSystem {
      specialArgs = {
        inherit hostname;
        inherit (self.hosts.${hostname}) username;
      };
      modules = [self.modules.nixos.server] ++ mkNixosModules hostname;
    };
  };
}
