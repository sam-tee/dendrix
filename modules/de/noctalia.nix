{
  self,
  inputs,
  ...
}: {
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
      nix.settings = {
        extra-substituters = ["https://noctalia.cachix.org"];
        extra-trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];
      };
      hardware.bluetooth.enable = true;
      services = {
        tuned.enable = true;
        upower.enable = true;
      };
      environment.systemPackages = [inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default];
    };
    homeManager.noctalia = {config, ...}: let
      bgDirFull = "${config.home.homeDirectory}/${bgDir}";
      bgDir = ".cache/noctalia/wallpapers";
    in {
      imports = [inputs.noctalia.homeModules.default];
      home.file = {
        "${bgDir}/bg.png".source = self.cosmetic.bgFile;
        ".cache/noctalia/wallpapers.json".text = builtins.toJSON {defaultWallpaper = "${bgDirFull}/bg.png";};
      };
      programs.noctalia-shell = {
        enable = true;
        colors = with self.cosmetic.theme.attrs; {
          mPrimary = base0E;
          mOnPrimary = base00;
          mSecondary = base0D;
          mOnSecondary = base01;
          mTertiary = base0B;
          mOnTertiary = base01;
          mError = base08;
          mOnError = base01;
          mSurface = base00;
          mOnSurface = base05;
          mHover = base0C;
          mOnHover = base01;
          mSurfaceVariant = base02;
          mOnSurfaceVariant = base04;
          mOutline = base03;
          mShadow = base00;
        };
        settings = {
          bar = {
            barType = "simple";
            position = "left";
            density = "mini";
            showCapsule = false;
            showOutline = false;
            backgroundOpacity = 1.0;
            enableExclusionZoneInset = false;
            widgets = {
              left = [
                {
                  id = "Launcher";
                  useDistroLogo = true;
                }
                {
                  id = "Clock";
                  formatHorizontal = "dd MMM | HH:mm";
                  formatVertical = "HH mm - dd MM";
                }
              ];
              center = [
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
                  id = "ControlCenter";
                  useDistroLogo = false;
                  icon = "settings-2";
                }
                {
                  id = "SessionMenu";
                  iconColor = "error";
                }
              ];
            };
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
          general = {
            enableShadows = false;
            radiusRatio = 0;
            iRadiusRatio = 0;
            animationDisabled = true;
            compactLockScreen = true;
            autoStartAuth = true;
            allowPasswordWithFprintd = true;
          };
          ui = {
            panelBackgroundOpacity = 1.0;
            scrollbarAlwaysVisible = false;
          };
          location.weatherShowEffects = false;
          wallpaper = {
            enabled = true;
            directory = bgDirFull;
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
