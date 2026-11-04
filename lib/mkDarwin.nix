{
  inputs,
  lib,
  self,
  ...
}: {
  mkDarwin = hostname: let
    inherit (self.modules) generic darwin;
    inherit (self.hosts.${hostname}) username system pubKey modules;
  in {
    ${hostname} = inputs.nix-darwin.lib.darwinSystem {
      # Hand our extended lib to darwin modules too (defaults to nixpkgs' lib)
      inherit lib;
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
