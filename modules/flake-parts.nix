{inputs, ...}: {
  flake-file.inputs.nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
  flake-file.formatter = pkgs: pkgs.alejandra;
  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "aarch64-darwin"
  ];
  imports = [inputs.flake-file.flakeModules.dendritic];
  perSystem = {pkgs, ...}: {
    formatter = pkgs.alejandra;
  };
}
