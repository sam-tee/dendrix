{
  flake.modules.nixos.torrent = {config, ...}: let
    inherit (config.homelab) domain group user;
  in {
    services = {
      qbittorrent = {
        enable = true;
        inherit group user;
        webuiPort = 4095;
      };
      caddy.virtualHosts."qbit.${domain}" = {
        useACMEHost = domain;
        extraConfig = ''
          reverse_proxy http://127.0.0.1:4095
        '';
      };
    };
  };
}
