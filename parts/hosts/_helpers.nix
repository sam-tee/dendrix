inputs: let
  pubKeys = import ./_pubKeys.nix;
  nMod = inputs.self.modules.nixos;
  hMod = inputs.self.modules.homeManager;
  dMod = inputs.self.modules.darwin;
in {
  mkDarwin = {
    hostname,
    username ? "sam",
    darwinModules ? [],
    homeModules ? [],
  }:
    inputs.nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = {inherit inputs username;};
      modules =
        darwinModules
        ++ (with dMod; [
          _default
          hm
          {
            networking.hostName = hostname;
            users.users.${username}.openssh.authorizedKeys.keys = [pubKeys.${hostname}];
            home-manager.sharedModules = homeModules ++ [hMod._minimal];
          }
        ]);
    };

  mkNixos = {
    hostname,
    username ? "sam",
    system ? "x86_64-linux",
    nixosModules ? [],
    homeModules ? [],
  }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {inherit inputs username;};
      modules =
        nixosModules
        ++ (with nMod; [
          _default
          hm
          ./_harware/${hostname}.nix
          {
            networking.hostName = hostname;
            networking.useNetworkd = true;
            users.users.${username}.openssh.authorizedKeys.keys = [pubKeys.${hostname}];
            home-manager.sharedModules = homeModules ++ [hMod._linuxMinimal];
          }
        ]);
    };

  mkMobile = {
    hostname,
    username ? "sam",
    device,
    nixosModules ? [],
    homeModules ? [],
  }:
    inputs.nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = {inherit inputs username;};
      modules =
        nixosModules
        ++ (with nMod; [
          _mobile
          hm
          ./_harware/${hostname}.nix
          (import "${inputs.mobile-nixos}/lib/configuration.nix" {inherit device;})
          {
            networking.hostName = hostname;
            users.users.${username}.openssh.authorizedKeys.keys = [pubKeys.${hostname}];
            home-manager.sharedModules = homeModules ++ [hMod._linuxMinimal];
          }
        ]);
    };

  mkServer = {
    hostname,
    username ? "sam",
    system ? "x86_64-linux",
    nixosModules ? [],
  }:
    inputs.nixpkgs-stable.lib.nixosSystem {
      inherit system;
      specialArgs = {inherit inputs username;};
      modules =
        nixosModules
        ++ [
          nMod._serverMin
          ./_harware/${hostname}.nix
          {
            networking.hostName = hostname;
            users.users.${username}.openssh.authorizedKeys.keys = [pubKeys.${hostname}];
          }
        ];
    };

  mkHome = {
    username,
    system,
    homeModules ? [],
  }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      extraSpecialArgs = {inherit username inputs;};
      modules = homeModules ++ [hMod.standalone];
    };
}
