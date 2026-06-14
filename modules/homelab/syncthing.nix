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
      devices = ["a3" "deck" "hp" "s340" "u410"];
    };
    Docs = {
      path = "~/Documents";
      devices = ["a3" "duet3" "hp" "mba" "oracle" "s340" "u410"];
    };
  };
in {
  flake.modules = {
    nixos.syncthing = {config, ...}: let
      inherit (config.homelab) group user dataDir;
      folders = allFolders |> lib.filterAttrs (_: v: lib.elem config.networking.hostName v.devices);
    in {
      sops.secrets."syncPwd".owner = user;
      services.syncthing = {
        enable = true;
        inherit user group dataDir;
        guiAddress = "0.0.0.0:8384";
        openDefaultPorts = true;
        guiPasswordFile = config.sops.secrets."syncPwd".path;
        settings = {
          gui.user = "sam";
          inherit devices folders;
        };
      };
    };
    homeManager.syncthing = {
      hostname,
      lib,
      ...
    }: let
      folders = lib.filterAttrs (_: v: lib.elem hostname v.devices) allFolders;
    in {
      services.syncthing = {
        enable = true;
        settings = {inherit devices folders;};
      };
    };
  };
}
