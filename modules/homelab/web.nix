{
  flake.modules.nixos.homelab = {config, ...}: let
    inherit (config.homelab) domain group user dataDir;
  in {
    systemd.tmpfiles.rules = [
      "d ${dataDir}/www 0755 ${user} ${group} -"
      "d ${dataDir}/test 0755 ${user} ${group} -"
    ];
    services.caddy.virtualHosts = {
      "${domain}" = {
        useACMEHost = domain;
        extraConfig = ''
          root * ${dataDir}/www
          file_server browse
        '';
      };
      "test.${domain}" = {
        useACMEHost = domain;
        extraConfig = ''
          root * ${dataDir}/test
          file_server browse
        '';
      };
      "router.${domain}" = {
        useACMEHost = domain;
        extraConfig = ''
          reverse_proxy http://192.168.1.1:80 {
            header_up Host {upstream_hostport}
          }
        '';
      };
    };
  };
}
