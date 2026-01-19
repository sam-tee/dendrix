{
  flake.modules.nixos.navidrome = {config, ...}: let
    inherit (config.homelab) group user;
  in {
    homelab.ingress.music = "4533";
    services.navidrome = {
      enable = true;
      openFirewall = true;
      inherit group user;
      settings = {
        MusicFolder = "/var/lib/media/music";
        DataFolder = "/var/lib/media/navidrome";
      };
    };
  };
}
