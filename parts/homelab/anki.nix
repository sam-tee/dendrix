{
  flake.modules.nixos.anki = {config, ...}: {
    sops.secrets."anki/sam" = {};
    services.anki-sync-server = {
      address = "127.0.0.1";
      enable = true;
      openFirewall = true;
      users = [
        {
          username = "sam";
          passwordFile = config.sops.secrets."anki/sam".path;
        }
      ];
    };
  };
}
