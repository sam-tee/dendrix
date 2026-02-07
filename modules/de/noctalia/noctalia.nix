{
  flake-file.inputs.noctalia = {
    url = "github:noctalia-dev/noctalia-shell";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake.modules = {
    nixos.noctalia = {
      inputs,
      pkgs,
      ...
    }: {
      hardware.bluetooth.enable = true;
      services = {
        power-profiles-daemon.enable = true;
        upower.enable = true;
      };
      environment.systemPackages = with pkgs; [
        inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
    homeManager.noctalia = {
      config,
      inputs,
      lib,
      ...
    }: let
      theme = lib.head config.cosmetic.themes;
    in {
      imports = [
        inputs.noctalia.homeModules.default
      ];

      xdg.configFile = {
        "noctalia/colorschemes/${theme.name}/${theme.name}.json".text = builtins.toJSON (import ./_palette.nix theme);
      };

      programs.noctalia-shell = {
        enable = true;
        systemd.enable = true;
        settings = {
          bar = {
            position = "top";
            density = "mini";
            showCapsule = false;
            widgets = {
              left = [
                {
                  id = "ControlCenter";
                  useDistroLogo = true;
                }
                {
                  id = "Workspace";
                  hideUnoccupied = false;
                  labelMode = "none";
                }
              ];
              center = [
                {
                  id = "Clock";
                  formatHorizontal = "dd MMM | HH:mm";
                  useMonospacedFont = true;
                  usePrimaryColor = true;
                }
              ];
              right = [
                {
                  id = "Tray";
                  hidePAssive = true;
                }
                {
                  id = "Network";
                  displayMode = "alwaysHide";
                }
                {
                  id = "Bluetooth";
                  displayMode = "alwaysHide";
                }
                {
                  displayMode = "graphic-clean";
                  id = "Battery";
                  showNoctaliaPerformance = true;
                  showPowerProfiles = true;
                }
                {
                  id = "SessionMenu";
                  iconColor = "error";
                }
              ];
            };
          };
          general = {
            radiusRatio = 0;
            iRadiusRatio = 0;
            animationDisabled = true;
            compactLockScreen = true;
            autoStartAuth = true;
            allowPasswordWithFprintd = true;
          };
          location = {
            name = "London, UK";
            weatherShowEffects = false;
          };
          ui = {
            fontDefault = "Inter";
            fontFixed = "Lilex Nerd Font Mono";
            panelBackgroundOpacity = 1;
          };
          wallpaper.enabled = false;
          appLauncher = {
            enableClipboardHistory = true;
            terminalCommand = "ghostty -e";
            showCategories = false;
          };
          controlCenter.cards = [
            {
              enabled = true;
              id = "profile-card";
            }
            {
              enabled = true;
              id = "shortcuts-card";
            }
            {
              enabled = true;
              id = "audio-card";
            }
            {
              enabled = true;
              id = "brightness-card";
            }
            {
              enabled = true;
              id = "weather-card";
            }
            {
              enabled = true;
              id = "media-sysmon-card";
            }
          ];
          dock.enabled = false;
          sessionMenu = {
            enableCountdown = false;
            showHeader = false;
            largeButtonsStyle = false;
          };
          audio.visualizerType = "none";
          colorSchemes.predefinedScheme = theme.name;
        };
      };
    };
  };
}
