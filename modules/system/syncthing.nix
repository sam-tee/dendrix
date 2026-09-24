{
  self,
  lib,
  ...
}: let
  devices =
    self.hosts
    |> lib.filterAttrs (_: value: (value.syncID or "") != "")
    |> builtins.mapAttrs (_: value: {
      id = value.syncID;
    });
  allDevices =
    self.hosts
    |> lib.filterAttrs (_: value: (value.syncID or "") != "")
    |> builtins.attrNames;
  allFolders = {
    project_data = {
      path = "~/data";
      devices = ["a3" "duet" "oracle" "u410"];
    };
    books = {
      path = "~/books";
      devices = ["a3" "duet" "hp" "mba" "oracle" "s340" "u410"];
    };
    calibre_config = {
      path = "~/.config/calibre";
      devices = ["a3" "hp" "mba" "oracle" "s340" "u410"];
    };
    Docs = {
      path = "~/Documents";
      devices = allDevices;
    };
    ai = {
      path = "~/.agents";
      devices = allDevices;
    };
  };
in {
  flake.modules = {
    darwin.default = self.modules.generic.syncthing;
    generic.syncthing = {
      config,
      username,
      ...
    }: let
      attrs =
        config.homelab or {
          user = username;
          group = "media";
          dataDir = config.users.users.${username}.home;
          machineIP = self.hosts.${config.networking.hostName}.tailscaleIP;
        };
      inherit (attrs) group user dataDir machineIP;
      folders = allFolders |> lib.filterAttrs (_: v: lib.elem config.networking.hostName v.devices);
      bindAddr =
        if machineIP == ""
        then "0.0.0.0"
        else machineIP;
    in {
      sops.secrets."syncPwd".owner = user;
      services.syncthing = {
        enable = true;
        inherit user group dataDir;
        guiAddress = "${bindAddr}:8384";
        guiPasswordFile = config.sops.secrets."syncPwd".path;
        settings = {
          gui.user = "sam";
          inherit devices folders;
        };
      };
    };
    nixos = {
      default = self.modules.generic.syncthing;
      caddy = {
        config,
        lib,
        ...
      }: {
        imports = [self.modules.generic.syncthing];
        services.caddy = {
          virtualHosts =
            devices
            |> lib.mapAttrs' (hostname: _:
              lib.nameValuePair "${hostname}.ts.${config.homelab.domain}" {
                useACMEHost = config.homelab.domain;
                extraConfig = ''
                  reverse_proxy http://${hostname}.${config.homelab.tailnetDomain}:8384
                '';
              });
        };
      };
    };
  };
}
