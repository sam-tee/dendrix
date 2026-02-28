{
  flake.modules.nixos.arr = {config, ...}: let
    inherit (config.homelab) domain group user;
  in {
    services = {
      jellyseerr = {
        enable = true;
        inherit group user;
      };
      caddy.virtualHosts."jellyseerr.${domain}" = {
        useACMEHost = domain;
        extraConfig = ''
          reverse_proxy http://127.0.0.1:5055
        '';
      };
    };
  };
}
