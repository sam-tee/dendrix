{
  flake.modules.darwin.options = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.programs.zoxide;

    cfgFlags = lib.strings.concatStringsSep " " cfg.flags;
  in {
    options.programs.zoxide = {
      enable = lib.mkEnableOption "zoxide, a smarter cd command that learns your habits";
      package = lib.mkPackageOption pkgs "zoxide" {};
      enableBashIntegration =
        lib.mkEnableOption "Bash integration"
        // {
          default = config.programs.bash.enable;
        };
      enableZshIntegration =
        lib.mkEnableOption "Zsh integration"
        // {
          default = config.programs.zsh.enable;
        };
      enableFishIntegration =
        lib.mkEnableOption "Fish integration"
        // {
          default = config.programs.fish.enable;
        };

      flags = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        example = [
          "--no-cmd"
          "--cmd j"
        ];
        description = ''
          List of flags for zoxide init
        '';
      };
    };
    config = lib.mkIf cfg.enable {
      environment.systemPackages = [cfg.package];

      programs = {
        zsh.interactiveShellInit = lib.mkIf cfg.enableZshIntegration ''
          eval "$(${lib.getExe cfg.package} init zsh ${cfgFlags} )"
        '';
        bash.interactiveShellInit = lib.mkIf cfg.enableBashIntegration ''
          eval "$(${lib.getExe cfg.package} init bash ${cfgFlags} )"
        '';
        fish.interactiveShellInit = lib.mkIf cfg.enableFishIntegration ''
          ${lib.getExe cfg.package} init fish ${cfgFlags} | source
        '';
      };
    };
  };
}
