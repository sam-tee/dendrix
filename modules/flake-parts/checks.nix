{
  lib,
  config,
  ...
}: {
  perSystem.checks =
    lib.mapAttrs
    (_: nixos: nixos.config.system.build.toplevel)
    config.flake.nixosConfigurations;
}
