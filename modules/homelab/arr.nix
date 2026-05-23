{self, ...}: let
  mkArrModule = name: {config, ...}: {
    services.${name} = {
      enable = true;
      inherit (config.homelab) group user;
      settings.server.port = self.services.lidarr.port;
    };
  };
in {
  flake.modules.nixos = {
    bazarr = {config, ...}: {
      services.bazarr = {
        enable = true;
        inherit (config.homelab) group user;
        listenPort = self.services.lidarr.port;
      };
    };
    radarr = mkArrModule "radarr";
    sonarr = mkArrModule "sonarr";
    lidarr = mkArrModule "lidarr";
    prowlarr = _: {
      services.prowlarr = {
        enable = true;
        settings.server.port = self.services.prowlarr.port;
      };
    };
    seerr = _: {
      services.seerr = {
        enable = true;
        inherit (self.services.seerr) port;
      };
    };
  };
}
