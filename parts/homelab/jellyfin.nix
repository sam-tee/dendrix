{
  flake.modules.nixos.jellyfin = {username, ...}: {
    services.jellyfin = {
      enable = true;
      openFirewall = true;
      group = "media";
      user = username;
      dataDir = "/var/lib/media/jellyfin";
    };
  };
}
