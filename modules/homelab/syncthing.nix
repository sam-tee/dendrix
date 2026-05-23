{self, ...}: let
  devices =
    builtins.mapAttrs (name: value: {
      id = value.syncID;
    })
    self.hosts;
  allFolders = {
    project_data = {
      path = "~/data";
      devices = ["a3" "mba" "u410"];
      ignorePatterns = ["(?d).DS_Store"];
    };
    books = {
      path = "~/books";
      devices = ["a3" "hp" "s340" "u410"];
      ignorePatterns = ["(?d).DS_Store"];
    };
    calibre_config = {
      path = "~/.config/calibre";
      devices = ["a3" "deck" "hp" "s340" "u410"];
      ignorePatterns = ["(?d).DS_Store"];
    };
    Docs = {
      path = "~/Documents";
      devices = ["a3" "duet3" "hp" "mba" "s340" "u410"];
      ignorePatterns = ["(?d).DS_Store" ".venv" "result"];
    };
  };
in {
  flake.modules = {
    nixos.syncthing = {
      config,
      lib,
      ...
    }: let
      inherit (config.homelab) group user dataDir;
      folders = lib.filterAttrs (_: v: lib.elem config.networking.hostName v.devices) allFolders;
    in {
      sops.secrets."syncPwd".owner = user;
      services.syncthing = {
        enable = true;
        inherit user group dataDir;
        configDir = "${dataDir}/syncthing";
        guiAddress = "0.0.0.0:${toString self.services.syncthing.port}";
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
