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
        default = self.modules.${type}.hjem;
        hjem = {username, ...}: {
          imports = [inputs.hjem."${type}Modules".default];
          hjem = {
            clobberByDefault = true;
            users = {
              ${username} = {};
              root.directory =
                if type == "darwin"
                then "/var/root"
                else "/root";
            };
          };
        };
      };
    })
    |> builtins.listToAttrs;
}
