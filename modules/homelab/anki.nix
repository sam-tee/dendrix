{
  flake.modules.nixos.anki = {config, ...}: let
    inherit (config.homelab) dataDir machineIP;
  in {
    sops.secrets."anki/samPwd" = {};
    services.anki-sync-server = {
      address = machineIP;
      enable = true;
      baseDirectory = dataDir;
      users = [
        {
          username = "sam";
          passwordFile = config.sops.secrets."anki/samPwd".path;
        }
      ];
    };
  };
}
