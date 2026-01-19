{
  flake.modules.nixos.audiobookshelf = {config, ...}: let
    inherit (config.homelab) group user;
  in {
    homelab.ingress.abs = "8000";
    services = {
      audiobookshelf = {
        enable = true;
        openFirewall = true;
        inherit group user;
        dataDir = "media/audiobooks";
      };
    };
  };
}
