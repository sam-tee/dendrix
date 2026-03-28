{inputs, ...}: {
  flake-file.inputs = {
    secrets = {
      url = "git+ssh://git@github.com/sam-tee/nix-secrets.git";
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
      sops = {
        defaultSopsFile = "${toString inputs.secrets}/secrets.yaml";
        age = {
          generateKey = true;
          keyFile = "/var/lib/sops-key.txt";
        };
      };
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
          keyFile = "${config.home.homeDirectory}/.sops-key.txt";
        };
      };
    };
  };
}
