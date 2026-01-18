{
  flake.module = {
    nixos.syncthing = {config, ...}: let
      cfg = config.homelab;
    in {
      services.syncthing = {
        enable = true;
        inherit (cfg) user group;
        configDir = "/var/lib/media/syncthing";
      };
    };
    homeManager.syncthing = _: {
      services.syncthing = {
        enable = true;
      };
    };
  };
}
