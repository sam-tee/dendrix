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
    };
  };
}
