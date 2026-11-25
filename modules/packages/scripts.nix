_: {
  perSystem = {
    inputs',
    lib,
    ...
  }: {
    packages = lib.genAttrs [
      "cliproxy-usage-ntfy"
      "deploy-py"
      "nhw"
      "nixpkgs-pr-tracker"
      "sports-ntfy"
    ] (name: inputs'.${name}.packages.default);
  };
}
