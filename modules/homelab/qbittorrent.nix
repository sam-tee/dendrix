{self, ...}: {
  flake.modules.nixos.qbittorrent = {config, ...}: let
    inherit (config.homelab) group user;
  in {
    services.qbittorrent = {
      enable = true;
      inherit group user;
      webuiPort = self.services.qbittorrent.port;
    };
  };
}
