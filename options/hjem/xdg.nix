# Applies the system-level `xdg.dirs` options (options/generic/xdg.nix) to hjem
{
  flake.modules.hjem.xdg = {
    config,
    lib,
    osConfig,
    ...
  }: let
    inherit (lib) mkDefault mkIf;
    inherit (osConfig.xdg.dirs) cacheDir configDir dataDir homeDir stateDir;
  in {
    # Only sync the primary user; other hjem users (e.g. root) keep
    # directories derived from their own home.
    config = mkIf (config.directory == homeDir) {
      xdg = {
        config.directory = mkDefault configDir;
        cache.directory = mkDefault cacheDir;
        data.directory = mkDefault dataDir;
        state.directory = mkDefault stateDir;
      };
    };
  };
}
