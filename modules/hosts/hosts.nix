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
        darwinModules = with dMod; [];
        homeModules = with hMod; [
          aerospace
          extraPkgs
          syncthing
          vscode
        ];
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
        nixosModules = with nMod; [hyprland];
        homeModules = with hMod; [syncthing hyprTouch];
      };
      hp = mkNixos {
        hostname = "hp";
        username = "sam";
        nixosModules = with nMod; [hyprland];
        homeModules = with hMod; [linuxExtraPkgs syncthing];
      };
      s340 = mkNixos {
        hostname = "s340";
        username = "sam";
        nixosModules = with nMod; [hyprland];
        homeModules = with hMod; [linuxExtraPkgs syncthing];
      };
      u410 = mkServer {
        hostname = "u410";
        username = "sam";
        nixosModules = with nMod; [
          arr
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
