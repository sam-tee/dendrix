{
  flake.modules.nixos.arr = {
    config,
    lib,
    ...
  }: let
    inherit (config.homelab) domain group user;
    mkService = {
      enable = true;
      inherit group user;
    };
    mkHost = name: port: {
      "${name}.${domain}" = {
        useACMEHost = domain;
        extraConfig = ''
          reverse_proxy http://127.0.0.1:${lib.toString port}
        '';
      };
    };
  in {
    services = {
      bazarr = mkService;
      jellyseerr.enable = true;
      lidarr = mkService;
      prowlarr.enable = true;
      radarr = mkService;
      sonarr = mkService;
      caddy.virtualHosts = lib.mkMerge [
        (mkHost "bazarr" 6767)
        (mkHost "jellyseerr" 5055)
        (mkHost "lidarr" 8686)
        (mkHost "prowlarr" 9696)
        (mkHost "radarr" 7878)
        (mkHost "sonarr" 8989)
      ];
    };
  };
}
