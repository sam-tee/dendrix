# mirror nixpkgs nixos module for darwin
{
  flake.modules.darwin.options = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) getExe mkEnableOption mkIf mkOption mkPackageOption;
    inherit (lib.strings) concatStringsSep;
    inherit (lib.types) listOf str;
    cfg = config.programs.zoxide;

    cfgFlags = concatStringsSep " " cfg.flags;
  in {
    options.programs.zoxide = {
      enable = mkEnableOption "zoxide, a smarter cd command that learns your habits";
      package = mkPackageOption pkgs "zoxide" {};
      enableBashIntegration =
        mkEnableOption "Bash integration"
        // {
          default = config.programs.bash.enable;
        };
      enableZshIntegration =
        mkEnableOption "Zsh integration"
        // {
          default = config.programs.zsh.enable;
        };
      enableFishIntegration =
        mkEnableOption "Fish integration"
        // {
          default = config.programs.fish.enable;
        };

      flags = mkOption {
        type = listOf str;
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
    config = mkIf cfg.enable {
      environment.systemPackages = [cfg.package];

      programs = {
        zsh.interactiveShellInit = mkIf cfg.enableZshIntegration ''
          eval "$(${getExe cfg.package} init zsh ${cfgFlags} )"
        '';
        bash.interactiveShellInit = mkIf cfg.enableBashIntegration ''
          eval "$(${getExe cfg.package} init bash ${cfgFlags} )"
        '';
        fish.interactiveShellInit = mkIf cfg.enableFishIntegration ''
          ${getExe cfg.package} init fish ${cfgFlags} | source
        '';
      };
    };
  };
}
