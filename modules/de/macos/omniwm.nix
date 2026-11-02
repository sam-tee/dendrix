# Testing module for OmniWM (Niri scrolling + Hyprland Dwindle BSP).
# Enable by setting flake.hosts.<name>.modules = ["omniwm"] (replaces
# "aerospace": OmniWM refuses to manage windows while AeroSpace/Paneru are running).
# Options live in modules/options/omniwm.nix.
_: {
  flake.modules.darwin.omniwm = {
    services.omniwm = {
      enable = true;
      # Mirrors modules/de/macos/paneru.nix: Niri scrolling everywhere,
      # focus-follows-mouse, zero gaps, half-width columns, 3-finger swipe,
      # same ctrl-cmd-hjkl / ctrl-1..9 chords. Paneru's north=j/south=k
      # bindings are corrected to k-up/j-down here.
      settings = {
        schemaVersion = 5;

        general = {
          hotkeysEnabled = true;
          systemHyperTrigger = "None";
          hyperKeyModifiers = "Control+Option+Shift+Command";
          defaultLayoutType = "niri";
          preventSleepEnabled = false;
          updateChecksEnabled = false;
          ipcEnabled = false;
          animationsEnabled = true;
        };

        focus = {
          followsMouse = true;
          edgeNavigationInterval = 1.5;
          raiseOnMouseFocus = true;
          lockModifier = "off";
          moveMouseToFocusedWindow = true;
          followsWindowToMonitor = true;
          crossesMonitorAtEdge = false;
          moveCrossesMonitorAtEdge = false;
        };

        mouseWarp = {
          margin = 1;
          enabled = true;
          constrainToArrangement = false;
        };

        routing = {
          mode = "macOS";
          arrangements = [];
        };

        gaps = {
          size = 0.0;
          fullscreenUsesOuterGaps = false;
          outer = {
            left = 0.0;
            right = 0.0;
            top = 0.0;
            bottom = 0.0;
          };
        };

        niri = {
          visibleContainerCount = 2;
          infiniteLoop = false;
          centerFocusedColumn = "never";
          alwaysCenterSingleColumn = false;
          singleWindowFit = "fill";
          defaultContainerPrimarySpan = 0.5;
        };

        dwindle = {
          smartSplit = false;
          defaultSplitRatio = 1.0;
          splitWidthMultiplier = 1.0;
          singleWindowFit = "fill";
          useGlobalGaps = true;
          moveToRootStable = true;
        };

        borders = {
          enabled = true;
          width = 5.0;
          color = {
            red = 0.0846;
            green = 1.0;
            blue = 0.9793;
            alpha = 1.0;
          };
        };

        overview = {
          zoom = 1.0;
          backdrop = {
            red = 0.05;
            green = 0.05;
            blue = 0.08;
            alpha = 0.0;
          };
          windowBorders = {
            normal = {
              red = 0.3;
              green = 0.3;
              blue = 0.35;
              alpha = 0.5;
            };
            hovered = {
              red = 0.4;
              green = 0.6;
              blue = 1.0;
              alpha = 1.0;
            };
            selected = {
              red = 0.3;
              green = 0.8;
              blue = 0.4;
              alpha = 1.0;
            };
          };
        };

        workspaceBar = {
          enabled = true;
          showLabels = true;
          showFloatingWindows = false;
          windowLevel = "popup";
          position = "overlappingMenuBar";
          notchMode = "moveBelowMenuBar";
          notchActiveZoneWidth = 180.0;
          systemStatsButton = false;
          deduplicateAppIcons = false;
          hideEmptyWorkspaces = false;
          excludedBundleIDs = [];
          iconOverrides = {};
          reserveLayoutSpace = false;
          revealModifier = "off";
          revealHoldMilliseconds = 200.0;
          hideInNativeFullscreen = false;
          height = 24.0;
          backgroundOpacity = 0.1;
          xOffset = 0.0;
          yOffset = 0.0;
        };

        gestures = {
          scrollEnabled = true;
          scrollSensitivity = 5.0;
          scrollModifierKey = "optionShift";
          mouseMoveModifierKey = "option";
          mouseResizeModifierKey = "option";
          fingerCount = 3;
          invertDirection = true;
          trackpadScrollStyle = "snap";
          workspaceSwipeEnabled = true;
          workspaceSwipeFingerCount = 3;
          workspaceSwipeAxis = "vertical";
        };

        statusBar = {
          showWorkspaceName = false;
          showAppNames = false;
          useWorkspaceId = false;
        };

        hiddenBar = {
          enabled = true;
          hiddenBundleIDs = [];
          rehideIntervalSeconds = 5.0;
        };

        clipboard = {
          historyEnabled = false;
          maxItems = 200;
          maxItemBytes = 8388608;
          maxTotalBytes = 67108864;
        };

        quakeTerminal = {
          enabled = true;
          position = "center";
          widthPercent = 50.0;
          heightPercent = 50.0;
          animationDuration = 0.2;
          autoHide = false;
          backgroundEffect = "standardBlur";
        };

        scratchpads.labels = {};

        appearance.mode = "dark";

        hotkeys = [
          {
            id = "focus.left";
            binding = "Control+Command+H";
          }
          {
            id = "focus.right";
            binding = "Control+Command+L";
          }
          {
            id = "focus.up";
            binding = "Control+Command+K";
          }
          {
            id = "focus.down";
            binding = "Control+Command+J";
          }
          {
            id = "move.left";
            binding = "Control+Command+Shift+H";
          }
          {
            id = "move.right";
            binding = "Control+Command+Shift+L";
          }
          {
            id = "move.up";
            binding = "Control+Command+Shift+K";
          }
          {
            id = "move.down";
            binding = "Control+Command+Shift+J";
          }
          {
            id = "switchWorkspace.0";
            binding = "Control+1";
          }
          {
            id = "switchWorkspace.1";
            binding = "Control+2";
          }
          {
            id = "switchWorkspace.2";
            binding = "Control+3";
          }
          {
            id = "switchWorkspace.3";
            binding = "Control+4";
          }
          {
            id = "switchWorkspace.4";
            binding = "Control+5";
          }
          {
            id = "switchWorkspace.5";
            binding = "Control+6";
          }
          {
            id = "switchWorkspace.6";
            binding = "Control+7";
          }
          {
            id = "switchWorkspace.7";
            binding = "Control+8";
          }
          {
            id = "switchWorkspace.8";
            binding = "Control+9";
          }
          {
            id = "moveToWorkspace.0";
            binding = "Control+Shift+1";
          }
          {
            id = "moveToWorkspace.1";
            binding = "Control+Shift+2";
          }
          {
            id = "moveToWorkspace.2";
            binding = "Control+Shift+3";
          }
          {
            id = "moveToWorkspace.3";
            binding = "Control+Shift+4";
          }
          {
            id = "moveToWorkspace.4";
            binding = "Control+Shift+5";
          }
          {
            id = "moveToWorkspace.5";
            binding = "Control+Shift+6";
          }
          {
            id = "moveToWorkspace.6";
            binding = "Control+Shift+7";
          }
          {
            id = "moveToWorkspace.7";
            binding = "Control+Shift+8";
          }
          {
            id = "moveToWorkspace.8";
            binding = "Control+Shift+9";
          }
          {
            id = "centerColumn";
            binding = "Control+Command+M";
          }
          {
            id = "cycleWindowPrimarySpanForward";
            binding = "Control+Command+R";
          }
          {
            id = "toggleContainerFullPrimarySpan";
            binding = "Control+Command+F";
          }
          {
            id = "toggleFocusedWindowFloating";
            binding = "Control+Command+V";
          }
          {
            id = "toggleColumnTabbed";
            binding = "Control+Command+Period";
          }
          {
            id = "expelWindowFromColumn";
            binding = "Control+Command+Comma";
          }
          {
            id = "focusMonitorNext";
            binding = "Control+Command+Tab";
          }
          {
            id = "focusMonitorPrevious";
            binding = "Control+Command+Shift+Tab";
          }
        ];

        workspaces = [
          {
            id = "AD36F001-C57E-41A5-AC1D-DF5249D007F0";
            name = "1";
            monitorAssignment.type = "main";
            layoutType = "niri";
          }
          {
            id = "454CECD4-5E9D-4ED1-95D7-979D48817F5F";
            name = "2";
            monitorAssignment.type = "main";
            layoutType = "niri";
          }
          {
            id = "BEB842B5-E894-4791-9FD1-397C3CDD3538";
            name = "3";
            monitorAssignment.type = "main";
            layoutType = "niri";
          }
          {
            id = "248AA883-2261-4D45-943C-79C0E46A232B";
            name = "4";
            monitorAssignment.type = "main";
            layoutType = "niri";
          }
          {
            id = "8B8C45D6-CE9E-41D9-BD50-BE4989D5E3DE";
            name = "5";
            monitorAssignment.type = "main";
            layoutType = "niri";
          }
          {
            id = "5953F2BF-A378-4266-91B2-287174C4FA4D";
            name = "6";
            displayName = "❤️";
            monitorAssignment.type = "secondary";
            layoutType = "niri";
          }
          {
            id = "A7D5E104-6985-4516-8ED5-07F144F2A33D";
            name = "7";
            displayName = "🚀";
            monitorAssignment.type = "secondary";
            layoutType = "niri";
          }
          {
            id = "0E18F6B0-345A-4078-8B21-33641F07A861";
            name = "8";
            monitorAssignment.type = "main";
            layoutType = "niri";
          }
          {
            id = "8D4D711C-2B2F-4FEC-86BF-FA952037738A";
            name = "9";
            monitorAssignment.type = "main";
            layoutType = "niri";
          }
        ];

        appRules = [
          {
            id = "6A31F08A-4051-4354-B439-42F4C71894A3";
            bundleId = "com.openai.codex";
            minWidth = 800.0;
            minHeight = 600.0;
          }
          {
            id = "4BA546DA-2875-4BEF-B13F-1539E833B1A0";
            bundleId = "com.eltima.cmd1.pro.mas";
            minWidth = 950.0;
            minHeight = 550.0;
          }
          {
            id = "486CEFA6-69AA-4A3C-AF27-BCD38F4F138B";
            bundleId = "com.google.Chrome";
            minWidth = 500.0;
            minHeight = 375.0;
          }
          {
            id = "979F05F4-FFA2-4EDD-B23F-08A9944C759F";
            bundleId = "dev.zed.Zed";
            minWidth = 360.0;
            minHeight = 240.0;
          }
          {
            id = "81426D13-C1A5-475E-AFBC-00BBA05042D0";
            bundleId = "com.apple.Safari";
            minWidth = 574.0;
            minHeight = 220.0;
          }
          {
            id = "1CF39647-F30D-4E76-9686-79B551F1B094";
            bundleId = "app.zen-browser.zen";
            minWidth = 500.0;
            minHeight = 495.0;
          }
          {
            id = "005C00D3-F665-47F8-BDAE-D80790E9E46B";
            bundleId = "org.mozilla.firefox";
            minWidth = 500.0;
            minHeight = 120.0;
          }
          {
            id = "C21156B1-0224-4998-97E3-8F4FA65B9F3B";
            bundleId = "company.thebrowser.dia";
            minWidth = 500.0;
            minHeight = 420.0;
          }
          {
            id = "2DE9390B-0DB4-4D0C-9ABA-06F76F1D4EA9";
            bundleId = "com.spotify.client";
            minWidth = 800.0;
            minHeight = 600.0;
          }
          {
            id = "AF752D95-8497-4844-BE20-4C93E73BAEF2";
            bundleId = "com.hnc.Discord";
            minWidth = 800.0;
            minHeight = 500.0;
          }
          {
            id = "7876C9EF-437E-4D4F-9C27-B1B02F4AABCE";
            bundleId = "com.mitchellh.ghostty";
            minWidth = 90.0;
            minHeight = 48.0;
          }
          {
            id = "8ECAB78B-BCDD-4245-BC25-1609A49B1C86";
            bundleId = "com.microsoft.Outlook";
            minWidth = 930.0;
            minHeight = 650.0;
          }
          {
            id = "552FB77D-BF0E-4737-90A6-B5BC6986C579";
            bundleId = "com.apple.MobileSMS";
            minWidth = 660.0;
            minHeight = 320.0;
          }
          {
            id = "950075BA-9036-4957-9CA5-99724BB49594";
            bundleId = "";
            titleRegex = "Picture.*(in)?.*[Pp]icture";
            layout = "float";
          }
        ];
      };
    };
  };
}
