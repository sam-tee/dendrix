{self, ...}: let
  mkArrModule = name: {
    config,
    lib,
    ...
  }: let
    inherit (self.services.${name}) port;
    ip = config.homelab.machineIP;
  in {
    systemd.services.${name}.waitForTailscaleIP = true;
    services.${name} =
      {
        enable = true;
        settings =
          if name == "bazarr"
          then {general = {inherit ip port;};}
          else {
            server = {
              inherit port;
              bindAddress = ip;
            };
          };
      }
      // lib.optionalAttrs (name != "prowlarr") {
        inherit (config.homelab) group user;
      };
  };
in {
  flake.modules.nixos = {
    bazarr = mkArrModule "bazarr";
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
