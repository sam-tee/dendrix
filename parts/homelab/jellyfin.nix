{
  flake.modules.nixos.jellyfin = {config, ...}: let
    cfg = config.homelab;
  in {
    services.jellyfin = {
      enable = true;
      openFirewall = true;
      group = cfg.group;
      user = cfg.user;
      dataDir = "/var/lib/media/jellyfin";
    };
  };
}
