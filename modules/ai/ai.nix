{
  lib,
  moduleWithSystem,
  self,
  ...
}: let
  inherit (lib) singleton;
in {
  flake.modules.generic = {
    default = self.modules.generic.ai;
    ai = moduleWithSystem ({inputs', ...}: _: {
      environment = {
        variables.T3CODE_BASE_DIR = "$XDG_CONFIG_HOME/t3";
        systemPackages = with inputs'.ai.packages; [opencode];
      };
      hjem.extraModules = singleton {
        # intentionally blank for now
      };
    });
  };
}
