{inputs, ...}: let
  inherit (import ./_helpers.nix inputs) mkNixos mkDarwin mkHome mkServer mkMobile;
  dMod = inputs.self.modules.darwin;
  hMod = inputs.self.modules.homeManager;
  nMod = inputs.self.modules.nixos;
in {
  flake = {
    darwinConfigurations = {
      mba = mkDarwin {
        hostname = "mba";
        username = "sam";
        darwinModules = with dMod; [aerospace];
        homeModules = with hMod; [extraPkgs syncthing vscode];
      };
    };
    homeConfigurations = {
      deck = mkHome {
        username = "deck";
        system = "x86_64-linux";
        homeModules = with hMod; [
          {targets.genericLinux.enable = true;}
          _minimal
          cliLinux
          linuxMinPkgs
          plasma
          pointer
          xournal
        ];
      };
    };
    nixosConfigurations = {
      a3 = mkNixos {
        hostname = "a3";
        username = "sam";
        nixosModules = with nMod; [plasmaHM steam];
        homeModules = with hMod; [linuxExtraPkgs syncthing vscode];
      };
      duet3 = mkMobile {
        hostname = "duet3";
        username = "sam";
        device = "lenovo-wormdingler";
        nixosModules = with nMod; [plasmaMobileHM];
        homeModules = with hMod; [syncthing vscode];
      };
      hp = mkNixos {
        hostname = "hp";
        username = "sam";
        nixosModules = with nMod; [hyprlandHM];
        homeModules = with hMod; [linuxExtraPkgs syncthing];
      };
      s340 = mkNixos {
        hostname = "s340";
        username = "sam";
        nixosModules = with nMod; [hyprlandHM];
        homeModules = with hMod; [linuxExtraPkgs syncthing vscode];
      };
      u410 = mkServer {
        hostname = "u410";
        username = "sam";
        nixosModules = with nMod; [
          atuin
          calibre
          cockpit
          code-server
          copyparty
          forgejo
          immich
          jellyfin
          mealie
          syncthing
          tandoor
          vaultwarden
        ];
      };
    };
  };
}
