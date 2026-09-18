{self, ...}: {
  flake.modules.nixos.site = {config, ...}: let
    inherit (config.homelab) dataDir group user;
    inherit (self.services.site) port;
    wwwRoot = "${dataDir}/www";
  in {
    systemd.tmpfiles.rules = [
      "d ${wwwRoot} 0755 ${user} ${group} - -"
    ];

    services.caddy = {
      enable = true;
      inherit group user;
      virtualHosts.":${toString port}" = {
        extraConfig = ''
          bind ${self.hosts.${config.networking.hostName}.tailscaleIP}
          root * ${wwwRoot}
          file_server
        '';
      };
    };
  };
}
