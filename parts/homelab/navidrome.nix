{
  flake.modules.nixos.navidrome = {
    services = {
      navidrome = {
        enable = true;
        openFirewall = true;
        group = "media";
        settings = {
          MusicFolder = "/var/lib/media/music";
          DataFolder = "/var/lib/media/navidrome";
        };
      };
    };
  };
}
