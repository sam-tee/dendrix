{
  flake.modules.nixos.homelab = {
    config,
    lib,
    ...
  }: let
    inherit (config.homelab) tunnel ingress domain;
  in {
    sops.secrets = {
      "cloudflared/cert.pem" = {};
      "cloudflared/credentials.json" = {};
    };
    services.cloudflared = {
      enable = true;
      certificateFile = config.sops.secrets."cloudflared/cert.pem".path;
      tunnels.${tunnel} = {
        default = "http_status:503";
        credentialsFile = config.sops.secrets."cloudflared/credentials.json".path;
        ingress =
          lib.mapAttrs' (key: value: {
            name = "${key}.${domain}";
            value = "http://localhost:${value}";
          })
          ingress;
      };
    };
  };
}
