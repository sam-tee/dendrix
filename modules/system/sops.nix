{
  inputs,
  self,
  ...
}: let
  sopsPath = "${self}/nix-secrets/secrets.yaml";
in {
  flake-file.inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake.modules = {
    nixos.system = _: {
      imports = [inputs.sops-nix.nixosModules.sops];
      sops.defaultSopsFile = sopsPath;
    };
    darwin.system = _: {
      imports = [inputs.sops-nix.darwinModules.sops];
      sops.defaultSopsFile = sopsPath;
    };
    homeManager.sops = {config, ...}: {
      imports = [inputs.sops-nix.homeManagerModules.sops];
      sops = {
        defaultSopsFile = sopsPath;
        age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      };
    };
  };
}
