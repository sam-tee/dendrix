{
  moduleWithSystem,
  self,
  ...
}: {
  flake.modules.generic = {
    default = self.modules.generic.ai;
    ai = moduleWithSystem ({inputs', ...}: _: {
      environment.systemPackages = with inputs'.ai.packages; [
        opencode
        opencode2
      ];
    });
  };
}
