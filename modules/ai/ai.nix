{
  moduleWithSystem,
  self,
  ...
}: {
  flake.modules.generic = {
    default = self.modules.generic.ai;
    ai = moduleWithSystem ({inputs', ...}: _: {
      environment.systemPackages = with inputs'.ai.packages; [
        claude-code
        opencode2
        opencode2-desktop
      ];
    });
  };
}
