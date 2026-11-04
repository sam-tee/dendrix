# mirror nixpkgs nixos module for darwin
{lib, ...}: let
  inherit (lib) escapeShellArgs getExe literalExpression mkEnableOption mkIf mkOption mkPackageOption;
  inherit (lib.types) listOf str;
in {
  flake.modules.darwin.options = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.programs.atuin;

    tomlFormat = pkgs.formats.toml {};

    settingsFile = tomlFormat.generate "atuin-config" cfg.settings;
  in {
    options.programs.atuin = {
      enable = mkEnableOption "atuin";

      package = mkPackageOption pkgs "atuin" {};

      enableBashIntegration =
        mkEnableOption "Bash integration"
        // {
          default = config.programs.bash.enable;
          defaultText = literalExpression "config.programs.bash.enable";
        };

      enableZshIntegration =
        mkEnableOption "Zsh integration"
        // {
          default = config.programs.zsh.enable;
          defaultText = literalExpression "config.programs.zsh.enable";
        };

      flags = mkOption {
        type = listOf str;
        default = [];
        example = [
          "--disable-up-arrow"
          "--disable-ctrl-r"
        ];
        description = ''
          Flags to append to the shell hook.
        '';
      };

      settings = mkOption {
        inherit (tomlFormat) type;
        default = {};
        example = literalExpression ''
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
    config = mkIf cfg.enable {
      environment = {
        systemPackages = [cfg.package];
        variables.ATUIN_CONFIG_DIR = "/etc/atuin";
        etc = mkIf (cfg.settings != {}) {
          "atuin/config.toml".source = settingsFile;
        };
      };
      programs.bash.interactiveShellInit = mkIf cfg.enableBashIntegration ''
        if [[ :$SHELLOPTS: =~ :(vi|emacs): ]]; then
          eval "$(${getExe cfg.package} init bash ${escapeShellArgs cfg.flags})"
        fi
      '';
      programs.zsh.interactiveShellInit = mkIf cfg.enableZshIntegration ''
        if [[ $options[zle] = on ]]; then
          eval "$(${getExe cfg.package} init zsh ${escapeShellArgs cfg.flags})"
        fi
      '';
    };
  };
}
