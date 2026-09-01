{self, ...}: {
  flake.modules.nixos.anki = {config, ...}: {
    sops.secrets."anki/samPwd" = {};
    services.anki-sync-server = {
      address = self.hosts.${config.networking.hostName}.tailscaleIP;
      enable = true;
      baseDirectory = config.homelab.dataDir;
      users = [
        {
          username = "sam";
          passwordFile = config.sops.secrets."anki/samPwd".path;
        }
      ];
    };
  };
}
