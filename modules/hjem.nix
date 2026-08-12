{
  inputs,
  self,
  ...
}: {
  flake-file.inputs.hjem = {
    url = "github:feel-co/hjem?ref=pull/167/merge";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake.modules =
    ["darwin" "nixos"]
    |> map (type: {
      name = type;
      value = {
        default = self.modules.${type}.hjem;
        hjem = {username, ...}: {
          imports = [inputs.hjem."${type}Modules".default];
          hjem = {
            clobberByDefault = true;
            extraModules = [self.modules.hjem.default];
            users.${username} = {};
          };
        };
      };
    })
    |> builtins.listToAttrs;
}
