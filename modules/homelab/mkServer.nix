{self, ...}: {
  flake.modules.nixos.mkServer = {
    hostname,
    lib,
    ...
  }: {
    imports =
      self.services
      |> (lib.filterAttrs (_: value: value.host == hostname))
      |> builtins.attrNames
      |> map (service: self.modules.nixos.${service});
  };
}
