{
  flake.modules.nixos.navidrome = {config, ...}: let
    cfg = config.homelab;
  in {
    services.navidrome = {
      enable = true;
      openFirewall = true;
      inherit (cfg) group user;
      settings = {
        MusicFolder = "/var/lib/media/music";
        DataFolder = "/var/lib/media/navidrome";
      };
    };
  };
}
