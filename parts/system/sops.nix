let
  sopsConf = inputs: {
    defaultSopsFile = "${builtins.toString inputs.secrets}/secrets.yaml";
    defaultSopsFormat = "yaml";
    defaultSopsKey = null;
    age = {
      sshKeyPaths = [];
      generateKey = true;
      keyFile = "/var/lib/sops-nix/key.txt";
    };
  };
in {
  flake.modules = {
    nixos.system = {inputs, ...}: {
      imports = [inputs.sops-nix.nixosModules.sops];
      sops = sopsConf inputs;
    };
    darwin.system = {inputs, ...}: {
      imports = [inputs.sops-nix.darwinModules.sops];
      sops = sopsConf inputs;
    };
    homeManager.system = {inputs, ...}: {
      imports = [inputs.sops-nix.homeManagerModules.sops];
      sops = sopsConf inputs;
    };
  };
}
