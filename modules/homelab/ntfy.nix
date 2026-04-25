{
  flake.modules.nixos.ntfy = {config, ...}: let
    inherit (config.homelab) domain;
    port = "4198";
  in {
    homelab.ingress.ntfy = port;
    services.ntfy-sh = {
        enable = true;
        settings = {
          base-url = "https://ntfy.${domain}";
          listen-http = ":${port}";
          upstream-base-url = "https://ntfy.sh";
          behind-proxy = true;
        };
      };
    };
  };
}
