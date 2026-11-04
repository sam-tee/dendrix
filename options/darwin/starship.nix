# mirror nixpkgs nixos module for darwin
{
  flake.modules.darwin.options = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkIf mkOption mkPackageOption;
    cfg = config.programs.starship;
    settingsFormat = pkgs.formats.toml {};
    settingsFile = settingsFormat.generate "starship.toml" cfg.settings;
  in {
    options.programs.starship = {
      enable = mkEnableOption "the Starship shell prompt";
      package = mkPackageOption pkgs "starship" {};
      settings = mkOption {
        inherit (settingsFormat) type;
        default = {};
        description = ''
          Configuration included in {file}`starship.toml`.

          See <https://starship.rs/config/#prompt> for documentation.
        '';
      };
    };
    config = mkIf cfg.enable {
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
