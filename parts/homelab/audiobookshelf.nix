{
  flake.modules.nixos.audiobookshelf = {username, ...}: {
    services = {
      audiobookshelf = {
        enable = true;
        openFirewall = true;
        user = username;
        group = "media";
        dataDir = "media/audiobooks";
      };
    };
  };
}
