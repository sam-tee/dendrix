{self, ...}: {
  flake.modules.nixos.share = {config, ...}: let
    inherit (config.homelab) dataDir group user;
    inherit (self.services.share) fqdn;
    shareRoot = "${dataDir}/share";
  in {
    systemd.tmpfiles.rules = [
      "d ${shareRoot} 0755 ${user} ${group} - -"
    ];

    services.caddy = {
      enable = true;
      inherit group user;
      virtualHosts."${fqdn}" = {
        useACMEHost = self.domain;
        extraConfig = ''
          encode zstd gzip
          root * ${shareRoot}
          file_server
        '';
      };
    };
  };
}
