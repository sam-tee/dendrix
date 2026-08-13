{
  flake.modules.darwin.options = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.programs.starship;
    settingsFormat = pkgs.formats.toml {};
    settingsFile = settingsFormat.generate "starship.toml" cfg.settings;
  in {
    options.programs.starship = {
      enable = lib.mkEnableOption "the Starship shell prompt";
      package = lib.mkPackageOption pkgs "starship" {};
      settings = lib.mkOption {
        inherit (settingsFormat) type;
        default = {};
        description = ''
          Configuration included in {file}`starship.toml`.

          See <https://starship.rs/config/#prompt> for documentation.
        '';
      };
    };
    config = lib.mkIf cfg.enable {
      environment.systemPackages = [cfg.package];
      programs.zsh.promptInit = ''
        if [[ $TERM != "dumb" ]] then
          if [[ ! -f "''${STARSHIP_CONFIG:-$HOME/.config/starship.toml}" ]]; then
            export STARSHIP_CONFIG=${settingsFile}
          fi
          eval "$(${cfg.package}/bin/starship init zsh)"
        fi
      '';
    };
  };
}
