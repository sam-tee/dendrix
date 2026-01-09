{
  flake.modules.nixos.immich = {
    services.immich = {
      enable = true;
      openFirewall = true;
      host = "0.0.0.0";
      group = "media";
      mediaLocation = "/var/lib/media/immich";
      database = {
        enable = true;
        createDB = true;
      };
      machine-learning.enable = false;
    };
  };
}
