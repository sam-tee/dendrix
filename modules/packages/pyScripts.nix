{self, ...}: {
  flake-file.inputs.pyScripts = {
    url = "git+https://${self.services.forgejo.fqdn}/sam-tee/python.git";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  perSystem = {inputs', ...}: {
    inherit (inputs'.pyScripts) packages;
  };
}
