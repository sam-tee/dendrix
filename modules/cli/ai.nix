{
  moduleWithSystem,
  self,
  ...
}: {
  flake-file.inputs.ai = {
    url = "github:numtide/llm-agents.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake.modules.generic = {
    default = self.modules.generic.ai;
    ai = moduleWithSystem ({inputs', ...}: _: {
      nix.settings = {
        extra-substituters = ["https://cache.numtide.com"];
        extra-trusted-public-keys = ["niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="];
      };
      environment.systemPackages = with inputs'.ai.packages; [opencode];
    });
  };
}
