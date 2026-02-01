{
  flake.modules.nixos.audiobookshelf = {config, ...}: let
    inherit (config.homelab) domain group user;
  in {
    services = {
      audiobookshelf = {
        enable = true;
        openFirewall = true;
        inherit group user;
        dataDir = "media/audiobooks";
      };
      caddy.virtualHosts."audio.${domain}" = {
        useACMEHost = domain;
        extraConfig = ''
          reverse_proxy http://127.0.0.1:8000
        '';
      };
    };
  };
}
