{inputs, ...}: {
  debug = true;
  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "aarch64-darwin"
  ];
  imports = [
    inputs.flake-file.flakeModules.dendritic
    inputs.flake-parts.flakeModules.modules
    inputs.home-manager.flakeModules.home-manager
  ];
}
