{
  flake.modules.nixos.navidrome = {config, ...}: let
    inherit (config.homelab) domain group user;
  in {
    homelab.ingress.music = "4533";
    services = {
      caddy.virtualHosts."music.${domain}" = {
        useACMEHost = domain;
        extraConfig = ''
          reverse_proxy http://127.0.0.1:4533
        '';
      };
      navidrome = {
        enable = true;
        openFirewall = true;
        inherit group user;
        settings = {
          MusicFolder = "/var/lib/media/music";
          DataFolder = "/var/lib/media/navidrome";
        };
      };
    };
  };
}
