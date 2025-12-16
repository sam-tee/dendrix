{
  config,
  inputs,
  pkgs,
  ...
}: {
  flake.modules.nixos.plasma = {
    environment = {
      systemPackages = with pkgs; [
        kdePackages.partitionmanager
        maliit-keyboard
      ];
      plasma6.excludePackages = with pkgs.kdePackages; [
        elisa
        kate
        konsole
        plasma-browser-integration
      ];
    };
    services = {
      displayManager.sddm = {
        enable = true;
        extraPackages = [pkgs.maliit-keyboard];
        settings.Wayland.CompositorCommand = "${pkgs.kdePackages.kwin}/bin/kwin_wayland --no-global-shortcuts --no-kactivities --no-lockscreen --locale1 --inputmethod maliit-keyboard";
        wayland.enable = true;
      };
      desktopManager.plasma6.enable = true;
    };
  };

  flake.modules.home.plasma = {
    imports = [inputs.plasma-manager.nixosModules.plasma-manager];
    programs = {
      okular = {
        enable = true;
        general = {
          openFileInTabs = true;
          smoothScrolling = true;
          zoomMode = "fitWidth";
        };
      };
      plasma = {
        enable = true;
        configFile = {
          "kdeglobals"."KDE"."AnimationDurationFactor" = 0;
          "kwinrc"."Windows"."FocusPolicy" = "FocusFollowsMouse";
        };
        fonts = let
          mkFont = family: size: {
            inherit family;
            pointSize = size;
          };
        in {
          fixedWidth = mkFont "Lilex Nerd Font Mono" 12;
          general = mkFont "Inter Variable" 12;
          menu = mkFont "Inter Variable" 12;
          small = mkFont "Inter Variable" 9;
          toolbar = mkFont "Inter Variable" 12;
          windowTitle = mkFont "Inter Variable" 12;
        };
        hotkeys.commands."launch-ghostty" = {
          name = "Launch Ghostty";
          key = "Meta+Return";
          command = "ghostty";
        };
        input.keyboard.options = ["caps:escape"];
        krunner = {
          position = "center";
          shortcuts.launch = "Meta+Space";
        };
        kwin = {
          effects = {
            blur = {
              enable = true;
              noiseStrength = 5;
              strength = 10;
            };
            desktopSwitching = {
              animation = "off";
              navigationWrapping = true;
            };
            minimization.animation = "off";
            shakeCursor.enable = true;
            translucency.enable = true;
            windowOpenClose.animation = "off";
          };
          nightLight.enable = false;
          titlebarButtons = {
            left = ["close" "minimize" "maximize"];
            right = [];
          };
          virtualDesktops.number = 4;
        };
        panels = [
          {
            hiding = "dodgewindows";
            lengthMode = "fit";
            location = "top";
            opacity = "translucent";
            widgets = [
              {kickoff.sortAlphabetically = true;}
              {
                digitalClock = {
                  time.format = "24h";
                  calendar.firstDayOfWeek = "monday";
                };
              }
              "org.kde.plasma.systemtray"
            ];
          }
          {
            hiding = "dodgewindows";
            lengthMode = "fit";
            location = "bottom";
            opacity = "translucent";
            widgets = [
              {
                iconTasks = {
                  behavior.showTasks = {
                    onlyInCurrentScreen = false;
                    onlyInCurrentDesktop = false;
                    onlyInCurrentActivity = false;
                    onlyMinimized = false;
                  };
                  iconsOnly = true;
                  launchers = [
                    "preferred://filemanager"
                    "preferred://browser"
                  ];
                };
              }
            ];
          }
        ];
        session = {
          general.askForConfirmationOnLogout = false;
        };
        shortcuts = {
          "kwin"."Switch to Desktop 1" = "Meta+1";
          "kwin"."Switch to Desktop 2" = "Meta+2";
          "kwin"."Switch to Desktop 3" = "Meta+3";
          "kwin"."Switch to Desktop 4" = "Meta+4";
          "kwin"."Window Close" = "Meta+Q";
          "plasmashell"."activate task manager entry 1" = "";
          "plasmashell"."activate task manager entry 2" = "";
          "plasmashell"."activate task manager entry 3" = "";
          "plasmashell"."activate task manager entry 4" = "";
          "plasmashell"."activate task manager entry 5" = "";
          "plasmashell"."activate task manager entry 6" = "";
          "plasmashell"."activate task manager entry 7" = "";
          "plasmashell"."activate task manager entry 8" = "";
          "plasmashell"."activate task manager entry 9" = "";
          "plasmashell"."manage activities" = "";
          "services/org.kde.dolphin.desktop"."_launch" = "Meta+F";
          "services/org.kde.konsole.desktop"."_launch" = [];
          "services/org.kde.krunner.desktop"."_launch" = "Meta+Space";
          "services/org.kde.plasma-systemmonitor.desktop"."_launch" = [];
          "services/org.kde.plasma.emojier.desktop"."_launch" = "Meta+Ctrl+Alt+Shift+Space";
        };
        spectacle.shortcuts = {
          launch = "Meta+Shift+S";
          recordRegion = "";
          recordScreen = "";
          recordWindow = "";
        };
        windows.allowWindowsToRememberPositions = true;
        workspace = {
          enableMiddleClickPaste = true;
          lookAndFeel = "org.kde.breezedark.desktop";
          colorScheme = "BreezeDark";
          wallpaper = "/home/${config.primaryUser.username}/${config.background.backgroundFile}";
          wallpaperFillMode = "stretch";
        };
      };
    };
  };
}
