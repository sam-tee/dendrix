{
  lib,
  self,
  ...
}: let
  inherit (lib) mkNixosModules nixosSystem;
in {
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
