{
  flake.modules.darwin.options = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) escapeShellArgs;

    cfg = config.programs.atuin;

    tomlFormat = pkgs.formats.toml {};

    settingsFile = tomlFormat.generate "atuin-config" cfg.settings;
  in {
    options.programs.atuin = {
      enable = lib.mkEnableOption "atuin";

      package = lib.mkPackageOption pkgs "atuin" {};

      enableBashIntegration =
        lib.mkEnableOption "Bash integration"
        // {
          default = config.programs.bash.enable;
          defaultText = lib.literalExpression "config.programs.bash.enable";
        };

      enableZshIntegration =
        lib.mkEnableOption "Zsh integration"
        // {
          default = config.programs.zsh.enable;
          defaultText = lib.literalExpression "config.programs.zsh.enable";
        };

      flags = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        example = [
          "--disable-up-arrow"
          "--disable-ctrl-r"
        ];
        description = ''
          Flags to append to the shell hook.
        '';
      };

      settings = lib.mkOption {
        type = tomlFormat.type;
        default = {};
        example = lib.literalExpression ''
          {
            auto_sync = true;
            sync_frequency = "5m";
            sync_address = "https://api.atuin.sh";
            search_mode = "prefix";
          }
        '';
        description = ''
          Configuration written to {file}`/etc/atuin/config.toml`.

          See <https://docs.atuin.sh/configuration/config/> for the full list
          of options.
        '';
      };
    };
    config = lib.mkIf cfg.enable {
      environment.systemPackages = [cfg.package];
      environment.variables.ATUIN_CONFIG_DIR = "/etc/atuin";
      environment.etc = lib.mkIf (cfg.settings != {}) {
        "atuin/config.toml".source = settingsFile;
      };
      programs.bash.interactiveShellInit = lib.mkIf cfg.enableBashIntegration ''
        if [[ :$SHELLOPTS: =~ :(vi|emacs): ]]; then
          eval "$(${lib.getExe cfg.package} init bash ${escapeShellArgs cfg.flags})"
        fi
      '';
      programs.zsh.interactiveShellInit = lib.mkIf cfg.enableZshIntegration ''
        if [[ $options[zle] = on ]]; then
          eval "$(${lib.getExe cfg.package} init zsh ${escapeShellArgs cfg.flags})"
        fi
      '';
    };
  };
}
