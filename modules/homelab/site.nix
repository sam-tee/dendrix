{self, ...}: {
  flake.modules.nixos.site = {config, ...}: let
    inherit (config.homelab) dataDir domain group machineIP user;
    inherit (self.services.site) fqdn;
    wwwRoot = "${dataDir}/www";
  in {
    systemd.tmpfiles.rules = [
      "d ${wwwRoot} 0755 ${user} ${group} - -"
    ];

    services.caddy = {
      enable = true;
      inherit group user;
      virtualHosts."${fqdn}" = {
        useACMEHost = domain;
        extraConfig = ''
          bind ${machineIP}
          root * ${wwwRoot}
          file_server
        '';
      };
    };
  };
}
