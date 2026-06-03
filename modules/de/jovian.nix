{inputs, ...}: {
  flake-file.inputs.jovian = {
    url = "github:jovian-experiments/jovian-nixos";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake.modules.nixos.jovian = {username, ...}: {
    imports = [inputs.jovian.nixosModules.default];
    jovian = {
      decky-loader.enable = true;
      steam = {
        enable = true;
        updater.splash = "vendor";
        autoStart = true;
        user = username;
        desktopSession = "hyprland-uwsm";
      };
      #steamos.useSteamOSConfig = true;
    };
  };
}
