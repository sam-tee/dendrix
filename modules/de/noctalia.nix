{inputs, ...}: {
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
    nixos.noctalia = {pkgs, ...}: {
      hardware.bluetooth.enable = true;
      services = {
        tuned.enable = true;
        upower.enable = true;
      };
      environment.systemPackages = [inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default];
    };
    homeManager.noctalia = _: {
      imports = [inputs.noctalia.homeModules.default];

      programs.noctalia-shell = {
        enable = true;
        settings = {
          bar = {
            barType = "simple";
            position = "left";
            density = "mini";
            showCapsule = false;
            showOutline = false;
            widgets = {
              left = [
                {
                  id = "ControlCenter";
                  useDistroLogo = true;
                }
                {
                  id = "Workspace";
                  hideUnoccupied = false;
                  labelMode = "index";
                  emptyColor = "none";
                  focusedColor = "primary";
                  occupiedColor = "secondary";
                  pillSize = 0.6;
                }
              ];
              center = [
                {
                  id = "Clock";
                  formatHorizontal = "dd MMM | HH:mm";
                  formatVertical = "HH mm - dd MM";
                }
              ];
              right = [
                {
                  id = "Tray";
                  hidePassive = true;
                  chevronColor = "none";
                  drawerEnabled = true;
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
          ui.scrollbarAlwaysVisible = false;
          location.weatherShowEffects = false;
          wallpaper = {
            enabled = true;
            skipStartupTransition = true;
            fillMode = "stretch";
          };
          appLauncher = {
            enableClipboardHistory = true;
            terminalCommand = "ghostty -e";
            showCategories = false;
          };
          dock.enabled = false;
          sessionMenu = {
            enableCountdown = false;
            showHeader = false;
            largeButtonsStyle = false;
          };
          audio.visualizerType = "none";
          idle = {
            enabled = true;
            screenOffTimeout = 299;
            lockTimeout = 300;
            suspendTimeout = 600;
          };
        };
      };
    };
  };
}
