{inputs, ...}: let
  inherit (import ./_helpers.nix inputs) mkHome;
in {
  flake.homeConfigurations."deck" = mkHome {
    username = "deck";
    system = "x86_64-linux";
    homeModules = with inputs.self.modules.homeManager; [
    ];
  };
}
