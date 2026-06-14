{inputs, ...}: {
  flake-file.inputs = {
    secrets = {
      url = "git+ssh://forgejo@git-ssh.akhlus.uk:2222/sam-tee/nix-secrets.git";
      flake = false;
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  flake.modules = {
    nixos.system = _: {
      imports = [inputs.sops-nix.nixosModules.sops];
      sops.defaultSopsFile = "${toString inputs.secrets}/secrets.yaml";
    };
    darwin.system = _: {
      imports = [inputs.sops-nix.darwinModules.sops];
      sops.defaultSopsFile = "${toString inputs.secrets}/secrets.yaml";
    };
    homeManager.sops = {config, ...}: {
      imports = [inputs.sops-nix.homeManagerModules.sops];
      sops = {
        defaultSopsFile = "${toString inputs.secrets}/secrets.yaml";
        age = {
          generateKey = true;
          keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
        };
      };
    };
  };
}
