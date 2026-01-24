{
  flake.module = {
    nixos.syncthing = {config, ...}: let
      inherit (config.homelab) group user;
    in {
      homelab.ingress.sync = "8384";
      services.syncthing = {
        enable = true;
        inherit user group;
        configDir = "/var/lib/media/syncthing";
        dataDir = "/var/lib/media";
      };
    };
    homeManager.syncthing = _: {
      services.syncthing = {
        enable = true;
      };
    };
  };
}
