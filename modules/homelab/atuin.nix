{
  flake.modules.nixos.atuin = {config, ...}: let
    inherit (config.homelab) domain;
  in {
    services = {
      caddy.virtualHosts."atuin.${domain}" = {
        useACMEHost = domain;
        extraConfig = ''
          reverse_proxy http://127.0.0.1:8888
        '';
      };
      atuin = {
        enable = true;
        openFirewall = true;
        openRegistration = false;
        maxHistoryLength = 1024 * 16;
      };
    };
  };
}
