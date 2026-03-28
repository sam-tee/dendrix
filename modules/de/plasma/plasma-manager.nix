{inputs, ...}: {
  flake-file.inputs.plasma-manager = {
    url = "github:nix-community/plasma-manager";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.home-manager.follows = "home-manager";
  };
  flake.modules.homeManager.plasma = _: {
    imports = [inputs.plasma-manager.homeModules.plasma-manager];
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
          virtualDesktops.number = 9;
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
        session.general.askForConfirmationOnLogout = false;
        shortcuts = let
          mkNumberedAttrs = prefix: valueFn:
            builtins.listToAttrs (map (i: {
              name = "${prefix} ${toString i}";
              value = valueFn i;
            }) [1 2 3 4 5 6 7 8 9]);
          getSymbol = i: builtins.elemAt ["!" "\"" "£" "$" "%" "^" "&" "*" "("] (i - 1);
        in {
          kwin =
            (mkNumberedAttrs "Switch to Desktop" (i: "Meta+${toString i}"))
            // (mkNumberedAttrs "Window to Desktop" (i: "Meta+${getSymbol i}"))
            // {"Window Close" = "Meta+Q";};
          plasmashell =
            (mkNumberedAttrs "activate task manager entry" (i: ""))
            // {"manage activities" = "";};
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
        workspace = {
          enableMiddleClickPaste = true;
        };
      };
    };
  };
}
