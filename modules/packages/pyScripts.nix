_: {
  # deploy-py is vendored in ./deploy-py.nix (upstream still assumes the
  # old out-of-tree ~/nix-secrets repo), so it is excluded here.
  perSystem = {inputs', ...}: {
    packages = builtins.removeAttrs inputs'.pyScripts.packages ["deploy-py"];
  };
}
