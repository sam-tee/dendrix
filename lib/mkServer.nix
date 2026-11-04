{
  lib,
  self,
  ...
}: {
  # Like mkNixos, but also imports the shared headless-server module.
  mkServer = hostname: {
    ${hostname} = lib.nixosSystem {
      specialArgs = {
        inherit hostname;
        inherit (self.hosts.${hostname}) username;
      };
      modules = [self.modules.nixos.server] ++ lib.mkNixosModules hostname;
    };
  };
}
