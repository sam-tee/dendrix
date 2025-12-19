inputs: {
  mkDarwin = {
    hostname,
    username ? "sam",
    sshPubKey ? "",
    darwinModules ? [],
    homeModules ? [],
  }: let
    darwin = inputs.self.modules.darwin;
    home = inputs.self.modules.homeManager;
    hmModules.home-manager.sharedModules =
      homeModules
      ++ (with home; [
        minimal
      ]);
  in
    inputs.nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = {inherit inputs username;};
      modules =
        darwinModules
        ++ (with darwin; [
          default
          hm
          hmModules
          {networking.hostName = hostname;}
          {ssh.pubKey = sshPubKey;}
        ]);
    };

  mkNixos = {
    hostname,
    username ? "sam",
    system,
    sshPubKey ? "",
    nixosModules ? [],
    homeModules ? [],
  }: let
    nixos = inputs.self.modules.nixos;
    home = inputs.self.modules.homeManager;
    hmModules.home-manager.sharedModules =
      homeModules
      ++ (with home; [
        linuxMinimal
      ]);
  in
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {inherit inputs username;};
      modules =
        nixosModules
        ++ (with nixos; [
          default
          hm
          hmModules
          ./_harware/${hostname}.nix
          {networking.hostName = hostname;}
          {ssh.pubKey = sshPubKey;}
        ]);
    };

  mkServer = {
    hostname,
    username ? "server",
    system,
    sshPubKey ? "",
    nixosModules ? [],
  }: let
    nixos = inputs.self.modules.nixos;
  in
    inputs.nixpkgs-stable.lib.nixosSystem {
      inherit system;
      specialArgs = {inherit inputs username;};
      modules =
        nixosModules
        ++ (with nixos; [
          homelab
          ./_harware/${hostname}.nix
          {networking.hostName = hostname;}
          {ssh.pubKey = sshPubKey;}
        ]);
    };

  mkHome = {
    username,
    system,
    homeModules ? [],
  }: let
    home = inputs.self.modules.homeManager;
  in
    inputs.home-manager.lib.homeManagerConfigurations {
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      extraSpecialArgs = {inherit username inputs;};
      modules =
        homeModules
        ++ (with home; [
          standalone
        ]);
    };

  mkMobile = {
    hostname,
    username ? "sam",
    device,
    sshPubKey ? "",
    nixosModules ? [],
    homeModules ? [],
  }: let
    nixos = inputs.self.modules.nixos;
    home = inputs.self.modules.homeManager;
    hmModules.home-manager.sharedModules =
      homeModules
      ++ (with home; [
        linuxMinimal
      ]);
  in
    inputs.nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = {inherit inputs username;};
      modules =
        nixosModules
        ++ (with nixos; [
          mobile
          hm
          hmModules
          (import "${inputs.mobile-nixos}/lib/configuration.nix" {inherit device;})
          {
            networking.hostName = hostname;
            ssh.pubKey = sshPubKey;
          }
        ]);
    };
}
