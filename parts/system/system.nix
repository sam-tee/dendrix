{
  flake.modules.nixos.system = {
    hardware.enableAllFirmware = true;
    xdg.terminal-exec = {
      enable = true;
      settings.default = ["ghostty.desktop"];
    };
    services.xserver.xkb = {
      layout = "gb";
      variant = "";
    };
    system.stateVersion = "24.05";
    time.timeZone = "Europe/London";
    console.keyMap = "uk";
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

  flake.modules.darwin.system = {
    pkgs,
    username,
    ...
  }: {
    security.pam.services.sudo_local.touchIdAuth = true;
    system = {
      stateVersion = 6;
      primaryUser = username;
      defaults = {
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
          persistent-apps = [
            {app = "${pkgs.brave}/Applications/Brave Browser.app";}
            {app = "${pkgs.zed-editor}/Applications/Zed.app";}
            {app = "/Applications/Ghostty.app";}
            {app = "/Applications/Spotify.app";}
          ];
          show-process-indicators = true;
          show-recents = false;
          showhidden = true;
          tilesize = 34;
        };
        finder = {
          _FXShowPosixPathInTitle = true;
          _FXSortFoldersFirst = true;
          AppleShowAllFiles = true;
          CreateDesktop = false;
          FXPreferredViewStyle = "Nlsv";
          NewWindowTarget = "Home";
          QuitMenuItem = true;
          ShowExternalHardDrivesOnDesktop = false;
          ShowHardDrivesOnDesktop = false;
          ShowPathbar = true;
          ShowRemovableMediaOnDesktop = false;
        };
      };
      keyboard = {
        enableKeyMapping = true;
        remapCapsLockToEscape = true;
      };
    };
  };
}
