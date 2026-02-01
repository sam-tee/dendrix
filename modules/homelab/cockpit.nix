{
  flake.modules.nixos.cockpit = {config, ...}: {
    services = {
      caddy.virtualHosts."dash.${config.homelab.domain}" = {
        useACMEHost = config.homelab.domain;
        extraConfig = ''
          reverse_proxy http://127.0.0.1:9090
        '';
      };
      cockpit = {
        enable = true;
        openFirewall = true;
        allowed-origins = ["https://*.akhlus.uk" "https://*.samtee.uk" "https://192.168.*.*"];
      };
    };
  };
}
