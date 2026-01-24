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
        homeModules = with hMod; [extraPkgs vscode];
      };
    };
    homeConfigurations = {
      deck = mkHome {
        username = "deck";
        system = "x86_64-linux";
        homeModules = with hMod; [
          {targets.genericLinux.enable = true;}
          _linuxMinimal
        ];
      };
    };
    nixosConfigurations = {
      a3 = mkNixos {
        hostname = "a3";
        username = "sam";
        nixosModules = with nMod; [plasmaHM steam];
        homeModules = with hMod; [linuxExtraPkgs vscode];
      };
      duet3 = mkMobile {
        hostname = "duet3";
        username = "sam";
        device = "lenovo-wormdingler";
        nixosModules = with nMod; [plasmaHM];
        homeModules = with hMod; [vscode];
      };
      s340 = mkNixos {
        hostname = "s340";
        username = "sam";
        nixosModules = with nMod; [plasmaHM];
        homeModules = with hMod; [linuxExtraPkgs vscode];
      };
      u410 = mkServer {
        hostname = "u410";
        username = "sam";
        nixosModules = with nMod; [
          anki
          calibre
          cockpit
          code-server
          copyparty
          forgejo
          immich
          jellyfin
          nfs
          samba
          syncthing
          vaultwarden
        ];
      };
    };
  };
}
