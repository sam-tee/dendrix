{
  flake.modules.nixos.ntfy = {config, ...}: let
    inherit (config.homelab) domain;
    port = "4198";
  in {
    services = {
      caddy.virtualHosts."ntfy.${domain}" = {
        useACMEHost = domain;
        extraConfig = "reverse_proxy localhost:${port}";
      };
      ntfy-sh = {
        enable = true;
        settings = {
          base-url = "https://ntfy.${domain}";
          listen-http = ":${port}";
        };
      };
    };
  };
}
