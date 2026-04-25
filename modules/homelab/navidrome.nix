{
  flake.modules.nixos.navidrome = {config, ...}: let
    inherit (config.homelab) domain group user dataDir;
  in {
    homelab.ingress.music = "4533";
    services = {
      caddy.virtualHosts."navi.${domain}" = {
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
          MusicFolder = "${dataDir}/media/music";
          DataFolder = "${dataDir}/navidrome";
        };
      };
    };
  };
}
