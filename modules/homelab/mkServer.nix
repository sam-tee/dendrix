{self, ...}: {
  flake.modules.nixos.mkServer = {
    name,
    lib,
    ...
  }: {
    imports =
      self.services
      |> (lib.filterAttrs (_: value: value.host == name))
      |> builtins.attrNames
      |> map (service: self.modules.nixos.${service});
  };
}
