{self, ...}: {
  flake.modules.generic = {
    default = self.modules.generic.xdg;
    xdg = {
      config,
      lib,
      username,
      ...
    }: let
      inherit (lib) mkOption;
      inherit (lib.types) str;
      cfg = config.xdg.dirs;
    in {
      options.xdg.dirs = {
        homeDir = mkOption {
          type = str;
          default = config.users.users.${username}.home;
          defaultText = "config.users.users.<username>.home";
          description = "Home directory of the primary user. Base for the XDG directories.";
        };
        configDir = mkOption {
          type = str;
          default = "${cfg.homeDir}/.config";
          defaultText = "$HOME/.config";
          description = "XDG config directory (XDG_CONFIG_HOME).";
        };
        cacheDir = mkOption {
          type = str;
          default = "${cfg.homeDir}/.cache";
          defaultText = "$HOME/.cache";
          description = "XDG cache directory (XDG_CACHE_HOME).";
        };
        dataDir = mkOption {
          type = str;
          default = "${cfg.homeDir}/.local/share";
          defaultText = "$HOME/.local/share";
          description = "XDG data directory (XDG_DATA_HOME).";
        };
        stateDir = mkOption {
          type = str;
          default = "${cfg.homeDir}/.local/state";
          defaultText = "$HOME/.local/state";
          description = "XDG state directory (XDG_STATE_HOME).";
        };
      };
      # Sets each hjem user's XDG directories from these (see options/hjem/xdg.nix)
      config.hjem.extraModules = [self.modules.hjem.xdg];
    };
  };
}
