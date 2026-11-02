# mirror nixpkgs nixos module style for darwin (nix-darwin has no services.omniwm)
{
  flake.modules.darwin.options = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.services.omniwm;

    settingsFormat = pkgs.formats.toml {};
  in {
    options.services.omniwm = {
      enable = lib.mkEnableOption "OmniWM, a tiling window manager for macOS";
      package = lib.mkPackageOption pkgs "omniwm" {};

      settings = lib.mkOption {
        type = lib.types.nullOr settingsFormat.type;
        default = null;
        description = ''
          Declarative contents of {file}`~/.config/omniwm/settings.toml`.
          Null leaves the file GUI-managed (recommended while testing).
          A declared file is a read-only Nix-store symlink, so GUI saves fail while it is set.
        '';
      };
    };

    config = lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = !config.services.aerospace.enable;
          message = "omniwm refuses to manage windows while AeroSpace is running: remove \"aerospace\" from flake.hosts.<name>.modules to test omniwm.";
        }
      ];

      environment.systemPackages = [cfg.package];

      launchd.user.agents.omniwm = {
        command = "${cfg.package}/bin/OmniWM";
        serviceConfig = {
          KeepAlive = true;
          RunAtLoad = true;
        };
      };

      hjem.extraModules = lib.mkIf (cfg.settings != null) [
        {
          xdg.config.files."omniwm/settings.toml".source =
            settingsFormat.generate "omniwm-settings.toml" cfg.settings;
        }
      ];

      # OmniWM has native trackpad gestures; free up 3-finger swipes.
      system.defaults.trackpad = {
        TrackpadThreeFingerHorizSwipeGesture = 0;
        TrackpadThreeFingerVertSwipeGesture = 0;
      };
    };
  };
}
