{
  lib,
  self,
  ...
}: let
  inherit (self) hosts;
  inherit (lib) filterAttrs mapAttrs mkServer mkNixos mkMobile mkDarwin;
  builders = {
    server = mkServer;
    desktop = mkNixos;
    mobile = mkMobile;
  };
in {
  flake.nixosConfigurations =
    hosts
    |> filterAttrs (_: host: builders ? ${host.hostType})
    |> mapAttrs (hostname: host: (builders.${host.hostType} hostname).${hostname});

  flake.darwinConfigurations =
    hosts
    |> filterAttrs (_: host: host.hostType == "darwin")
    |> mapAttrs (hostname: _: (mkDarwin hostname).${hostname});
}
