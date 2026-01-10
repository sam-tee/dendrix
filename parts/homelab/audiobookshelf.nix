{
  flake.modules.nixos.audiobookshelf = {config, ...}: let
    cfg = config.homelab;
  in {
    services.audiobookshelf = {
      enable = true;
      openFirewall = true;
      group = cfg.group;
      user = cfg.user;
      dataDir = "media/audiobooks";
    };
  };
}
