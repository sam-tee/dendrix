{self, ...}: {
  flake.modules.nixos.site = {config, ...}: let
    inherit (config.homelab) dataDir domain group user;
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
          encode zstd gzip
          root * ${wwwRoot}
          file_server
        '';
      };
    };
  };
}
