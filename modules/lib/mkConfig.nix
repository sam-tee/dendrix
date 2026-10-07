{
  lib,
  self,
  ...
}: let
  inherit (self) hosts;
  inherit (self.lib) mkServer mkNixos mkMobile mkDarwin;
  inherit (lib) filterAttrs mapAttrs;
  builders = {
    server = mkServer;
    desktop = mkNixos;
    mobile = mkMobile;
  };
in {
  # Generate nixosConfigurations/darwinConfigurations from flake.hosts so
  # host files only declare metadata and host-specific modules.
  flake.nixosConfigurations =
    hosts
    |> filterAttrs (_: host: builders ? ${host.hostType})
    |> mapAttrs (hostname: host: (builders.${host.hostType} hostname).${hostname});

  flake.darwinConfigurations =
    hosts
    |> filterAttrs (_: host: host.hostType == "darwin")
    |> mapAttrs (hostname: _: (mkDarwin hostname).${hostname});
}
