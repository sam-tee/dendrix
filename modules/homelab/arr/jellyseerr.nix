{
  flake.modules.nixos.arr = {config, ...}: let
    inherit (config.homelab) domain;
  in {
    services = {
      jellyseerr.enable = true;
      caddy.virtualHosts."jellyseerr.${domain}" = {
        useACMEHost = domain;
        extraConfig = ''
          reverse_proxy http://127.0.0.1:5055
        '';
      };
    };
  };
}
