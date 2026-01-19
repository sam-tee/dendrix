{
  flake.module = {
    nixos.syncthing = {config, ...}: let
      inherit (config.homelab) group user;
    in {
      homelab.ingress.sync = "";
      services.syncthing = {
        enable = true;
        inherit user group;
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
