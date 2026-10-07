{
  inputs,
  lib,
  self,
  ...
}: let
  inherit (self.modules) generic darwin;
in {
  flake.lib.mkDarwin = hostname: let
    inherit (inputs.self.hosts.${hostname}) username system pubKey modules;
  in {
    ${hostname} = inputs.nix-darwin.lib.darwinSystem {
      specialArgs = {inherit hostname username;};
      modules =
        [
          generic.default
          darwin.default
          darwin.options
          {
            networking.hostName = hostname;
            nixpkgs.hostPlatform = lib.mkDefault system;
            system.primaryUser = username;
            system.stateVersion = 6;
            users.users.${username}.openssh.authorizedKeys.keys = [pubKey];
          }
        ]
        ++ map (name: darwin.${name}) modules
        ++ (
          if darwin ? ${hostname}
          then [darwin.${hostname}]
          else builtins.trace "warning: host '${hostname}' defines no 'darwin.${hostname}' module, skipping" []
        );
    };
  };
}
