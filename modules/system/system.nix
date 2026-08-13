{self, ...}: {
  flake.modules = {
    hjem.default = {config, ...}: {
      environment.sessionVariables = {
        XDG_CACHE_HOME = "${config.directory}/.cache";
        XDG_CONFIG_HOME = "${config.directory}/.config";
        XDG_DATA_HOME = "${config.directory}/.local/share";
        XDG_STATE_HOME = "${config.directory}/.local/state";
      };
    };
    nixos.default = self.modules.nixos.system;
    nixos.system = _: {
      system.stateVersion = "24.05";
      xdg.terminal-exec.enable = true;
      services.xserver.xkb = {
        layout = "gb";
        variant = "";
      };
      time.timeZone = "Europe/London";
      console.keyMap = "uk";
      documentation = {
        man.enable = true;
        info.enable = false;
        doc.enable = false;
        nixos.enable = false;
      };
      i18n = {
        defaultLocale = "en_GB.UTF-8";
        extraLocaleSettings = {
          LC_ADDRESS = "en_GB.UTF-8";
          LC_IDENTIFICATION = "en_GB.UTF-8";
          LC_MEASUREMENT = "en_GB.UTF-8";
          LC_MONETARY = "en_GB.UTF-8";
          LC_NAME = "en_GB.UTF-8";
          LC_NUMERIC = "en_GB.UTF-8";
          LC_PAPER = "en_GB.UTF-8";
          LC_TELEPHONE = "en_GB.UTF-8";
          LC_TIME = "en_GB.UTF-8";
        };
      };
    };
    darwin.default = self.modules.darwin.system;
    darwin.system = _: {
      documentation = {
        man.enable = true;
        info.enable = false;
        doc.enable = false;
      };
      security.pam.services.sudo_local.touchIdAuth = true;
      system = {
        stateVersion = 6;
        defaults = {
          LaunchServices.LSQuarantine = false;
          NSGlobalDomain = {
            AppleInterfaceStyle = "Dark";
            ApplePressAndHoldEnabled = false;
            AppleShowAllExtensions = true;
            AppleShowAllFiles = true;
            InitialKeyRepeat = 15;
            KeyRepeat = 2;
            NSAutomaticCapitalizationEnabled = false;
            NSAutomaticDashSubstitutionEnabled = false;
            NSAutomaticQuoteSubstitutionEnabled = false;
            NSAutomaticSpellingCorrectionEnabled = false;
            NSAutomaticWindowAnimationsEnabled = false;
            NSDocumentSaveNewDocumentsToCloud = false;
            NSWindowResizeTime = 0.001;
            PMPrintingExpandedStateForPrint = true;
            _HIHideMenuBar = true;
            "com.apple.trackpad.forceClick" = false;
          };
          WindowManager = {
            AppWindowGroupingBehavior = false;
            AutoHide = true;
            EnableStandardClickToShowDesktop = false;
            EnableTiledWindowMargins = false;
            EnableTilingByEdgeDrag = true;
            GloballyEnabled = false;
            HideDesktop = true;
            StageManagerHideWidgets = true;
            StandardHideDesktopIcons = true;
            StandardHideWidgets = true;
          };
          controlcenter = {
            BatteryShowPercentage = true;
            Sound = false;
            NowPlaying = true;
          };
          dock = {
            autohide = true;
            autohide-delay = 0.0;
            autohide-time-modifier = 0.0;
            expose-animation-duration = 0.0;
            largesize = 16;
            launchanim = false;
            magnification = false;
            mineffect = "scale";
            minimize-to-application = true;
            show-process-indicators = true;
            show-recents = false;
            showhidden = true;
            tilesize = 34;
            persistent-apps = [
              {app = "/Applications/Nix Apps/Helium.app";}
              {app = "/Applications/Nix Apps/Zed.app";}
              {app = "/Applications/Nix Apps/Ghostty.app";}
              {app = "/Applications/Nix Apps/Spotify.app";}
            ];
          };
          finder = {
            _FXShowPosixPathInTitle = true;
            _FXSortFoldersFirst = true;
            AppleShowAllFiles = true;
            CreateDesktop = false;
            FXPreferredViewStyle = "Nlsv";
            FXRemoveOldTrashItems = true;
            NewWindowTarget = "Home";
            QuitMenuItem = true;
            ShowExternalHardDrivesOnDesktop = false;
            ShowHardDrivesOnDesktop = false;
            ShowPathbar = true;
            ShowRemovableMediaOnDesktop = false;
            ShowStatusBar = true;
          };
          CustomUserPreferences = {
            "com.apple.Accessibility".ReduceMotionEnabled = 1;
            "com.apple.AdLib".allowApplePersonalizedAdvertising = false;
            "com.apple.screencapture" = {
              location = "~/Downloads";
              type = "png";
            };
            "com.apple.desktopservices" = {
              DSDontWriteNetworkStores = true;
              DSDontWriteUSBStores = true;
            };
          };
        };
        keyboard = {
          enableKeyMapping = true;
          remapCapsLockToEscape = true;
        };
      };
    };
  };
}
