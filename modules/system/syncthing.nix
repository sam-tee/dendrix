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
      devices = ["a3" "oracle" "u410"];
    };
    books = {
      path = "~/books";
      devices = ["a3" "hp" "mba" "oracle" "s340" "u410"];
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
        };
      inherit (attrs) group user dataDir;
      folders = allFolders |> lib.filterAttrs (_: v: lib.elem config.networking.hostName v.devices);
      tsIP = self.hosts.${config.networking.hostName}.tailscaleIP;
      bindAddr = if tsIP == "" then "0.0.0.0" else tsIP;
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
                  reverse_proxy http://${hostname}.scylla-goblin.ts.net:8384
                '';
              });
        };
      };
    };
  };
}
