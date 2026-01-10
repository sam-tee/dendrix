{
  flake.modules.nixos.navidrome = {config, ...}: let
    cfg = config.homelab;
  in {
    services.navidrome = {
      enable = true;
      openFirewall = true;
      group = cfg.group;
      user = cfg.user;
      settings = {
        MusicFolder = "/var/lib/media/music";
        DataFolder = "/var/lib/media/navidrome";
      };
    };
  };
}
