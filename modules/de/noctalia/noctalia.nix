{
  flake-file.inputs = {
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.noctalia-qs.follows = "noctalia-qs";
    };
    noctalia-qs = {
      url = "github:noctalia-dev/noctalia-qs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  flake.modules = {
    nixos.noctalia = {
      inputs,
      pkgs,
      ...
    }: {
      hardware.bluetooth.enable = true;
      services = {
        tuned.enable = true;
        upower.enable = true;
      };
      environment.systemPackages = [inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default];
    };
    homeManager.noctalia = {inputs, ...}: {
      imports = [inputs.noctalia.homeModules.default];

      programs.noctalia-shell = {
        enable = true;
        systemd.enable = true;
        settings = {
          bar = {
            position = "left";
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
        };
      };
    };
  };
}
