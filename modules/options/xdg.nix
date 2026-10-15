{
  self,
  lib,
  ...
}: let
  inherit (lib) mkDefault mkIf mkOption types;
in {
  flake.modules.generic = {
    default = self.modules.generic.xdg;
    xdg = {
      config,
      username,
      ...
    }: let
      cfg = config.xdg.dirs;
    in {
      options.xdg.dirs = {
        homeDir = mkOption {
          type = types.str;
          default = config.users.users.${username}.home;
          defaultText = "config.users.users.<username>.home";
          description = "Home directory of the primary user. Base for the XDG directories.";
        };
        configDir = mkOption {
          type = types.str;
          default = "${cfg.homeDir}/.config";
          defaultText = "$HOME/.config";
          description = "XDG config directory (XDG_CONFIG_HOME).";
        };
        cacheDir = mkOption {
          type = types.str;
          default = "${cfg.homeDir}/.cache";
          defaultText = "$HOME/.cache";
          description = "XDG cache directory (XDG_CACHE_HOME).";
        };
        dataDir = mkOption {
          type = types.str;
          default = "${cfg.homeDir}/.local/share";
          defaultText = "$HOME/.local/share";
          description = "XDG data directory (XDG_DATA_HOME).";
        };
        stateDir = mkOption {
          type = types.str;
          default = "${cfg.homeDir}/.local/state";
          defaultText = "$HOME/.local/state";
          description = "XDG state directory (XDG_STATE_HOME).";
        };
      };
      config.hjem.extraModules = [self.modules.hjem.xdg];
    };
  };
  flake.modules.hjem.xdg = {
    config,
    osConfig,
    ...
  }: let
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
