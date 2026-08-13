{
  inputs,
  lib,
  self,
  ...
}: {
  flake-file.inputs.nix-darwin = {
    url = "github:nix-darwin/nix-darwin/master";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake.lib.mkDarwin = hostname: let
    inherit (inputs.self.hosts.${hostname}) username system pubKey;
  in {
    ${hostname} = inputs.nix-darwin.lib.darwinSystem {
      specialArgs = {inherit hostname username;};
      modules = with self.modules; [
        generic.default
        darwin.default
        darwin.options
        darwin.${hostname}
        {
          networking.hostName = hostname;
          nixpkgs.hostPlatform = lib.mkDefault system;
          system.primaryUser = username;
          system.stateVersion = 6;
          users.users.${username}.openssh.authorizedKeys.keys = [pubKey];
        }
      ];
    };
  };
}
