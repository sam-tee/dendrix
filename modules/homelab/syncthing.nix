{self, ...}: let
  devices =
    builtins.mapAttrs (name: value: {
      id = value.syncID;
    })
    self.hosts;
  allFolders = {
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
      inherit (config.homelab) domain group user dataDir;
      folders = lib.filterAttrs (_: v: lib.elem config.networking.hostName v.devices) allFolders;
    in {
      sops.secrets."syncPwd".owner = user;
      services = {
        caddy.virtualHosts."sync.${domain}" = {
          useACMEHost = domain;
          extraConfig = ''
            reverse_proxy http://127.0.0.1:8384
          '';
        };
        syncthing = {
          enable = true;
          inherit user group dataDir;
          configDir = "${dataDir}/syncthing";
          guiAddress = "0.0.0.0:8384";
          openDefaultPorts = true;
          guiPasswordFile = config.sops.secrets."syncPwd".path;
          settings = {
            gui.user = "sam";
            inherit devices folders;
          };
        };
      };
    };
    homeManager.syncthing = {
      config,
      lib,
      osConfig,
      ...
    }: let
      hostname = osConfig.host.name or config.host.name;
      folders = lib.filterAttrs (_: v: lib.elem hostname v.devices) allFolders;
    in {
      services.syncthing = {
        enable = true;
        settings = {inherit devices folders;};
      };
    };
  };
}
