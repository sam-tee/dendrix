{
  flake.modules.nixos.jellyfin = {config, ...}: let
    inherit (config.homelab) group user dataDir;
  in {
    services.jellyfin = {
      enable = true;
      openFirewall = true;
      inherit group user;
      dataDir = "${dataDir}/jellyfin";
      cacheDir = "${dataDir}/jellyfin/cache";
    };
  };
}
