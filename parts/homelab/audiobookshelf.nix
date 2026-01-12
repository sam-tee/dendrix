{
  flake.modules.nixos.audiobookshelf = {config, ...}: let
    cfg = config.homelab;
  in {
    services.audiobookshelf = {
      enable = true;
      openFirewall = true;
      inherit (cfg) group user;
      dataDir = "media/audiobooks";
    };
  };
}
