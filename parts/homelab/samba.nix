{
  flake.modules.nixos.homelab = {
    services.samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          "workgroup" = "WORKGROUP";
          "server string" = "u410 share";
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
  };
}
