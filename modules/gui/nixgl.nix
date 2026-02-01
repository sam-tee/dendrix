{
  flake-file.inputs.nixgl.url = "github:nix-community/nixgl";
  flake.modules.homeManager.nixgl = {inputs, ...}: {
    nixGL = {
      inherit (inputs.nixgl) packages;
      installScripts = ["mesa"];
    };
  };
}
