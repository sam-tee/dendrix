let
  sopsConf = inputs: {
    defaultSopsFile = "${builtins.toString inputs.secrets}/secrets.yaml";
    sops.age = {
      keyFile = "/var/lib/sops-nix/key.txt";
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      generateKey = true;
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
