{inputs, ...}: {
  flake-file.inputs.disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake.modules.nixos.disko = _: {
    imports = [inputs.disko.nixosModules.disko];
  };
}
