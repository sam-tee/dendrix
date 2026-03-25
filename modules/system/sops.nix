{
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
    nixos.system = {inputs, ...}: {
      imports = [inputs.sops-nix.nixosModules.sops];
      sops = {
        defaultSopsFile = "${toString inputs.secrets}/secrets.yaml";
        age = {
          generateKey = true;
          keyFile = "/var/lib/sops-key.txt";
        };
      };
    };
    darwin.system = {inputs, ...}: {
      imports = [inputs.sops-nix.darwinModules.sops];
      sops.defaultSopsFile = "${toString inputs.secrets}/secrets.yaml";
    };
    homeManager.sops = {
      config,
      inputs,
      ...
    }: let
      homeDir = config.home.homeDirectory;
    in {
      imports = [inputs.sops-nix.homeManagerModules.sops];
      sops = {
        secrets.syncPwd = {};
        defaultSopsFile = "${toString inputs.secrets}/secrets.yaml";
        age = {
          generateKey = true;
          keyFile = "${homeDir}/.sops-key.txt";
        };
      };
    };
  };
}
