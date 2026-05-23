{
  flake.modules.nixos.cloudflared = {
    config,
    lib,
    ...
  }: let
    inherit (config.homelab) tunnel ingress domain;
  in {
    options.homelab = {
      ingress = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {};
        description = "Mapping of subdomain names to their backend ports.";
        example = {nextcloud = "8080";};
      };
      tunnel = lib.mkOption {
        type = lib.types.str;
        default = "";
        example = "00000000-0000-0000-0000-000000000000";
        description = "ID of cloudflared tunnel";
      };
    };
    config = {
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
            ingress
            |> lib.mapAttrs' (key: value: {
              name = "${key}.${domain}";
              value = "http://localhost:${value}";
            });
        };
      };
    };
  };
}
