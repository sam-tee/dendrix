{
  flake.modules.homeManager.nixgl = {inputs, ...}: {
    nixGL = {
      packages = inputs.nixgl.packages;
      installScripts = ["mesa"];
    };
  };
}
