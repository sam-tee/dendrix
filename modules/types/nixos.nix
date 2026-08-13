{
  inputs,
  lib,
  self,
  ...
}: {
  flake.lib.mkNixos = hostname: let
    inherit (inputs.self.hosts.${hostname}) username system pubKey;
  in {
    ${hostname} = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {inherit hostname username;};
      modules = with self.modules; [
        {
          networking.hostName = hostname;
          nixpkgs.hostPlatform = lib.mkDefault system;
          users.users.${username}.openssh.authorizedKeys.keys = [pubKey];
          system.stateVersion = "24.05";
        }
        generic.default
        nixos.default
        nixos.boot
        nixos.${hostname}
      ];
    };
  };
}
