{
  lib,
  self,
  ...
}: {
  # Expose every host's system closure as `packages.<system>.<hostname>` so the
  # cache workflow can hand them to nix-fast-build and push them to Attic.
  #
  # Declared via `perSystem` rather than `flake.packages` so flake-parts' own
  # transposition produces the `flake.packages.<system>` shape. Defining
  # `flake.packages` at the top level instead puts a definition of it in the
  # same module system that produces `self.modules`, which is a cycle waiting to
  # happen: `flake.packages` needs each host's `pkgs`, each host's `pkgs` needs
  # `self.modules`, and `self.modules` is what this system is in the middle of
  # computing.
  perSystem = {system, ...}: {
    packages = lib.mapAttrs (_: config: config.config.system.build.toplevel) (
      lib.filterAttrs (_: config: config.pkgs.stdenv.hostPlatform.system == system) (
        self.nixosConfigurations // self.darwinConfigurations
      )
    );
  };
}
