{
  flake.modules.nixos.microbin = {config, ...}: {
    sops.secrets."microbin.env" = {};
    networking.firewall.allowedTCPPorts = [ 8069 ];
    services = {
      microbin = {
        enable = true;
        dataDir = "/var/lib/media/microbin";
        passwordFile = config.sops.secrets."microbin.env".path;
        settings = {
          MICROBIN_PORT = 8069;
          MICROBIN_BIND = "127.0.0.1";
          MICROBIN_HIDE_LOGO = true;
          MICROBIN_HIGHLIGHTSYNTAX = true;
          MICROBIN_HIDE_HEADER = true;
          MICROBIN_HIDE_FOOTER = true;
        };
      };
    };
  };
}
