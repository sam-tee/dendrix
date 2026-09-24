{self, ...}: let
  mkArrModule = name: {
    config,
    lib,
    ...
  }: {
    services.${name} =
      {
        enable = true;
        settings.server = {
          port = self.services.${name}.port;
          bindAddress = config.homelab.machineIP;
        };
      }
      // lib.optionalAttrs (name != "prowlarr") {
        inherit (config.homelab) group user;
      };
  };
in {
  flake.modules.nixos = {
    bazarr = {config, ...}: {
      services.bazarr = {
        enable = true;
        inherit (config.homelab) group user;
        listenPort = self.services.bazarr.port;
      };
    };
    radarr = mkArrModule "radarr";
    sonarr = mkArrModule "sonarr";
    lidarr = mkArrModule "lidarr";
    prowlarr = mkArrModule "prowlarr";
    seerr = _: {
      services.seerr = {
        enable = true;
        inherit (self.services.seerr) port;
      };
    };
  };
}
