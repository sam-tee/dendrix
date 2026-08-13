{
  flake-file.inputs.pyScripts = {
    url = "git+https://git.akhlus.uk/sam-tee/python.git";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  perSystem = {inputs', ...}: {
    inherit (inputs'.pyScripts) packages;
  };
}
