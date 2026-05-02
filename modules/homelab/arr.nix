{
  flake.modules.nixos.arr = {
    config,
    lib,
    ...
  }: let
    inherit (config.homelab) domain group user dataDir;
    mkService = {
      enable = true;
      inherit group user;
    };
    mkHost = name: port: {
      "${name}.${domain}" = {
        useACMEHost = domain;
        extraConfig = ''
          reverse_proxy http://127.0.0.1:${toString port}
        '';
      };
    };
  in {
    sops.secrets.slskd = {};
    services = {
      bazarr = mkService;
      seerr.enable = true;
      lidarr = mkService;
      prowlarr.enable = true;
      radarr = mkService;
      sonarr = mkService;
      slskd = {
        inherit user group;
        enable = true;
        environmentFile = config.sops.secrets.slskd.path;
        settings.directories = {
          downloads = "${dataDir}/slskd/downloads";
          incomplete = "${dataDir}/slskd/incomplete";
        };
      };
      caddy.virtualHosts = lib.mkMerge [
        (mkHost "slskd" 5030)
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
