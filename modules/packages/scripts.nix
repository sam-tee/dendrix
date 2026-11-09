# Re-export the packages of the standalone script flakes (flake inputs).
_: {
  perSystem = {
    inputs',
    lib,
    ...
  }: {
    packages = lib.genAttrs [
      "deploy-py"
      "nhw"
      "nixpkgs-pr-tracker"
      "sports-ntfy"
    ] (name: inputs'.${name}.packages.default);
  };
}
