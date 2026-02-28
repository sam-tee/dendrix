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
  flake.modules = let
    sopsConf = inputs: {
      defaultSopsFile = "${toString inputs.secrets}/secrets.yaml";
      defaultSopsFormat = "yaml";
      age = {
        generateKey = false;
        keyFile = "/var/lib/sops-key.txt";
      };
    };
  in {
    nixos.system = {inputs, ...}: {
      imports = [inputs.sops-nix.nixosModules.sops];
      sops = sopsConf inputs;
    };
    darwin.system = {inputs, ...}: {
      imports = [inputs.sops-nix.darwinModules.sops];
      sops = sopsConf inputs;
    };
    homeManager.sops = {inputs, ...}: {
      imports = [inputs.sops-nix.homeManagerModules.sops];
      sops = sopsConf inputs;
    };
  };
}
