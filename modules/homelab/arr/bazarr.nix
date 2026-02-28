{
  flake.modules.nixos.arr = {config, ...}: let
    inherit (config.homelab) domain group user;
  in {
    services = {
      bazarr = {
        enable = true;
        inherit group user;
      };
      caddy.virtualHosts."bazarr.${domain}" = {
        useACMEHost = domain;
        extraConfig = ''
          reverse_proxy http://127.0.0.1:6767
        '';
      };
    };
  };
}
