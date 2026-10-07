{
  inputs,
  self,
  ...
}: let
  inherit (self.lib) mkNixosModules;
  inherit (self.modules.nixos) server;
in {
  # Like mkNixos, but also imports the shared headless-server module.
  flake.lib.mkServer = hostname: let
    inherit (inputs.self.hosts.${hostname}) username;
  in {
    ${hostname} = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {inherit hostname username;};
      modules = [server] ++ mkNixosModules hostname;
    };
  };
}
