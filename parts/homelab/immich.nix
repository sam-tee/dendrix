{
  flake.modules.nixos.immich = {
    services = {
      immich = {
        enable = true;
        openFirewall = true;
        host = "127.0.0.1";
        group = "media";
        mediaLocation = "/var/lib/media/immich";
        database = {
          enable = true;
          createDB = true;
        };
        machine-learning.enable = false;
      };
    };
  };
}
