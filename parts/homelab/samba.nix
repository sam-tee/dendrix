{
  flake.modules.nixos.samba = {config, username, ...}: {
    sops.secrets."samba" = {};
    services.samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          "workgroup" = "WORKGROUP";
          "server string" = "u410";
          "netbios name" = "u410";
          "security" = "user";
          "guest account" = "nobody";
          "map to guest" = "bad user";
        };
        media = {
          "path" = "var/lib/media";
          "browsable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0664";
          "directory mask" = "0775";
          "force group" = "media";
        };
      };
    };
    system.activationScripts = {
      init_smbpasswd.text = ''
        /run/current-system/sw/bin/printf "$(/run/current-system/sw/bin/cat ${config.sops.secrets.samba.path})\n$(/run/current-system/sw/bin/cat ${config.sops.secrets.samba.path})\n" | /run/current-system/sw/bin/smbpasswd -sa ${username}
      '';
    };
  };
}
