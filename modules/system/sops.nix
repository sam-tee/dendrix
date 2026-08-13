{
  inputs,
  self,
  ...
}: {
  flake-file.inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake.modules =
    ["darwin" "nixos"]
    |> map (type: {
      name = type;
      value = {
        default = self.modules.${type}.sops;
        sops = {
          imports = [inputs.sops-nix."${type}Modules".sops];
          sops.defaultSopsFile = "${self}/nix-secrets/secrets.yaml";
        };
      };
    })
    |> builtins.listToAttrs;
}
