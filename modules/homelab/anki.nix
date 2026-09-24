{
  flake.modules.nixos.anki = {config, ...}: let
    inherit (config.homelab) dataDir group machineIP user;
    ankiDir = "${dataDir}/anki";
  in {
    sops.secrets."anki/samPwd" = {};
    services.anki-sync-server = {
      address = machineIP;
      enable = true;
      baseDirectory = ankiDir;
      users = [
        {
          username = "sam";
          passwordFile = config.sops.secrets."anki/samPwd".path;
        }
      ];
    };
    systemd.services.anki-sync-server.serviceConfig = {
      ReadWritePaths = [ankiDir];
      SupplementaryGroups = [group];
    };
    systemd.tmpfiles.rules = [
      "d ${ankiDir} 0770 ${user} ${group} -"
      "z ${ankiDir} 0770 ${user} ${group} - -"
    ];
  };
}
