{
  flake.modules.homeManager.nixgl = {inputs, ...}: {
    nixGL = {
      inherit (inputs.nixgl) packages;
      installScripts = ["mesa"];
    };
  };
}
