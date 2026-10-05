{
  self,
  lib,
  ...
}: let
  inherit (self) domain tailnet;
  inherit (self.lib) mkTsIp;
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
          machineIP = mkTsIp hostName;
        };
      inherit (attrs) group user dataDir machineIP;
      inherit (config.networking) hostName;
      folders = allFolders |> lib.filterAttrs (_: v: lib.elem hostName v.devices);
    in {
      sops.secrets."syncPwd".owner = user;
      services.syncthing = {
        enable = true;
        inherit user group dataDir;
        guiAddress = "${machineIP}:8384";
        guiPasswordFile = config.sops.secrets."syncPwd".path;
        settings = {
          gui.user = "sam";
          inherit devices folders;
        };
      };
    };
    nixos = {
      default = self.modules.generic.syncthing;
      caddy = {lib, ...}: {
        services.caddy.virtualHosts =
          devices
          |> lib.mapAttrs' (hostname: _:
            lib.nameValuePair "${hostname}.${domain}" {
              useACMEHost = domain;
              extraConfig = ''
                reverse_proxy http://${hostname}.${tailnet}:8384
              '';
            });
      };
    };
  };
}
