{self, ...}: {
  flake.modules.nixos.immich = {config, ...}: let
    inherit (config.homelab) dataDir machineIP email;
    inherit (config.services.immich) user;
    inherit (self.services.immich) fqdn port;
  in {
    users.users.${user}.extraGroups = ["video" "render"];
    sops.secrets."immichSmtpPwd" = {
      key = "smtpPwd";
      owner = user;
    };
    services.immich = {
      enable = true;
      accelerationDevices = null;
      host = machineIP;
      inherit port;
      mediaLocation = "${dataDir}/immich";
      settings = {
        backup.database.keepLastAmount = 4;
        server.externalDomain = "https://${fqdn}";
        notifications.smtp = {
          enabled = true;
          from = "Immich <${email.from}>";
          transport = {
            inherit (email) host;
            port = 465;
            secure = true;
            username = email.user;
            password._secret = config.sops.secrets."immichSmtpPwd".path;
          };
        };
        storageTemplate = {
          enabled = true;
          template = "{{y}}/{{MM}}/{{dd}}/{{filename}}";
          hashVerificationEnabled = true;
        };
      };
    };
  };
}
