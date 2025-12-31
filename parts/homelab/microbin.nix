{
  flake.modules.nixos.microbin = {config, ...}: let
    port = 8069;
  in {
    sops.secrets."microbin.env" = {};
    networking.firewall.allowedTCPPorts = [port];
    services = {
      microbin = {
        enable = true;
        dataDir = "/var/lib/media/microbin";
        passwordFile = config.sops.secrets."microbin.env".path;
        settings = {
          MICROBIN_PORT = toString port;
          MICROBIN_BIND = "127.0.0.1";
          MICROBIN_HIGHLIGHTSYNTAX = true;
          MICROBIN_HIDE_LOGO = true;
          MICROBIN_HIDE_HEADER = true;
          MICROBIN_HIDE_FOOTER = true;
        };
      };
    };
  };
}
