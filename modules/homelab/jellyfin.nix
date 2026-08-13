{
  flake.modules.nixos.jellyfin = {config, ...}: let
    inherit (config.homelab) group user;
  in {
    services.jellyfin = {
      enable = true;
      inherit group user;
    };
  };
}
