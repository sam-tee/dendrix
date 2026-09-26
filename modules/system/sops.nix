{
  inputs,
  self,
  ...
}: {
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
