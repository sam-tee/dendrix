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
      environment.systemPackages = [inputs'.ai.packages.opencode];
    });
  };
}
