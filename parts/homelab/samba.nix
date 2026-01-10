{
  flake.modules.nixos.samba = {
    config,
    username,
    ...
  }: {
    sops.secrets."samba/samPwd" = {};
    services = {
      samba = {
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
      avahi.enable = true;
      samba-wsdd = {
        enable = true;
        openFirewall = true;
      };
    };
    systemd.services.samba-smbd.postStart = let
      users = [username];
      setupUser = user: let
        passwordPath = config.sops.secrets."samba/${user}Pwd".path;
        smbpasswd = "${config.services.samba.package}/bin/smbpasswd";
      in ''
        (echo $(< ${passwordPath});
         echo $(< ${passwordPath})) | \
          ${smbpasswd} -s -a ${user}
      '';
    in ''
      ${builtins.concatStringsSep "\n" (map setupUser users)}
    '';
  };
}
