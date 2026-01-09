{
  flake.modules.nixos.jellyfin = {
    services.jellyfin = {
      enable = true;
      openFirewall = true;
      group = "media";
      dataDir = "/var/lib/media/jellyfin";
    };
  };
}
