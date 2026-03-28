{inputs, ...}: {
  flake-file.inputs.nixgl.url = "github:nix-community/nixgl";
  flake.modules.homeManager.nixgl = _: {
    nixGL = {
      inherit (inputs.nixgl) packages;
      installScripts = ["mesa"];
    };
  };
}
