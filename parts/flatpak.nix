{
  flake.modules.homeManager.flatpak = {inputs, ...}: {
    imports = [inputs.nix-flatpak.homeManagerModules.nix-flatpak];
    services.flatpak = {
      enable = true;
      update.auto.enable = true;
      uninstallUnmanaged = true;
    };
  };
}
