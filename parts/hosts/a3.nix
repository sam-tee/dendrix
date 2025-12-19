{inputs, ...}: let
  inherit (import ./_helpers.nix inputs) mkNixos;
  hostname = "a3";
in {
  flake.nixosConfigurations."${hostname}" = mkNixos {
    inherit hostname;
    username = "sam";
    system = "x86_64-linux";
    nixosModules = [];
    homeModules = [];
  };
}
