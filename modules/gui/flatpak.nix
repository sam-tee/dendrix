{inputs, ...}: {
  flake-file.inputs.nix-flatpak.url = "github:gmodena/nix-flatpak";
  flake.modules.homeManager.flatpak = _: {
    imports = [inputs.nix-flatpak.homeManagerModules.nix-flatpak];
    services.flatpak = {
      enable = true;
      update.auto.enable = true;
      uninstallUnmanaged = true;
    };
  };
}
