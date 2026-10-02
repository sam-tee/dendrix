{self, ...}: {
  flake.modules.nixos = {
    default = {
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
    server = _: {
      security.sudo.wheelNeedsPassword = false;
    };
  };
}
