{
  flake.modules.nixos.homelab = {config, ...}: let
    inherit (config.homelab) domain group user;
    dir = config.users.users.${user}.home;
  in {
    systemd.tmpfiles.rules = [
      "d ${dir}/www 0755 ${user} ${group} -"
      "d ${dir}/test 0755 ${user} ${group} -"
    ];
    services.caddy.virtualHosts = {
      "${domain}" = {
        useACMEHost = domain;
        extraConfig = ''
          file_server browse
          root * ${dir}/www
        '';
      };
      "test.${domain}" = {
        useACMEHost = domain;
        extraConfig = ''
          root * ${dir}/test
          file_server /* browse
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
