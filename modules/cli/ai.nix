{
  lib,
  moduleWithSystem,
  self,
  ...
}: let
  inherit (lib) singleton;
in {
  flake-file.inputs.ai = {
    url = "github:numtide/llm-agents.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake.modules.generic = {
    default = self.modules.generic.ai;
    ai = moduleWithSystem ({inputs', ...}: _: {
      nix.settings = {
        extra-substituters = singleton "https://cache.numtide.com";
        extra-trusted-public-keys = singleton "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=";
      };
      environment.systemPackages = with inputs'.ai.packages; [opencode];
      hjem.extraModules = singleton {environment.sessionVariables.T3CODE_BASE_DIR = "$XDG_CONFIG_HOME/t3";};
    });
  };
}
