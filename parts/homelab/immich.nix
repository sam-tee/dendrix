{
  flake.modules.nixos.immich = {
    users.users.immich.extraGroups = ["video" "render"];
    services.immich = {
      enable = true;
      openFirewall = true;
      accelerationDevices = null;
      host = "0.0.0.0";
      group = "media";
      mediaLocation = "/var/lib/media/immich";
    };
  };
}
