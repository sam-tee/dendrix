{
  flake-file.inputs.jovian = {
    url = "github:jovian-experiments/jovian-nixos";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake.modules.nixos.jovian = {username, ...}: {
    decky-loader.enable = true;
    steam = {
      enable = true;
      updater.splash = "vendor";
      autoStart = true;
      user = username;
      desktopSession = "hyprland";
    };
    steamos.useSteamOSConfig = true;
  };
}
