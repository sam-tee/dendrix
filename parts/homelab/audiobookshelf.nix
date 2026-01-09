{
  flake.modules.nixos.audiobookshelf = {
    services.audiobookshelf = {
      enable = true;
      openFirewall = true;
      group = "media";
      dataDir = "media/audiobooks";
    };
  };
}
