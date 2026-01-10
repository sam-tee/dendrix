{
  flake.modules.nixos.homelab = {
    config,
    lib,
    ...
  }: {
    options.homelab = {
      cloudflared = {
        tunnel = lib.mkOption {
          type = lib.types.str;
          default = "";
          example = "00000000-0000-0000-0000-000000000000";
          description = "ID of tunnel";
        };
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
        tunnels.${config.homelab.cloudflared.tunnel} = {
          default = "http_status:404";
          credentialsFile = config.sops.secrets."cloudflared/credentials.json".path;
        };
      };
    };
  };
}
