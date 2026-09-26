{inputs, ...}: {
  flake.modules.nixos.default = inputs.disko.nixosModules.disko;
}
