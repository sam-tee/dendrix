{self, ...}: {
  flake.modules.nixos.server = {
    hostname,
    lib,
    ...
  }: {
    imports =
      self.services
      |> (lib.filterAttrs (_: value: value.host == hostname))
      |> builtins.attrNames
      |> map (service: self.modules.nixos.${service});
    security.sudo.wheelNeedsPassword = false;
  };
}
