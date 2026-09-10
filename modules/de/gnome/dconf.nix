{self, ...}: let
  inherit (self.cosmetic) bgFile fonts theme;
in {
  flake.modules.nixos.gnome = {lib, ...}: let
    inherit (lib.gvariant) mkEmptyArray type mkInt32;
    settings = {
      "org/gnome/TextEditor" = {
        restore-session = false;
      };

      "org/gnome/desktop/background" = {
        picture-uri = "file://${bgFile}";
        picture-uri-dark = "file://${bgFile}";
      };

      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-${theme.defaultVariant}";
        enable-animations = false;
        enable-hot-corners = false;
        font-name = "${fonts.ui.name} ${toString fonts.size}";
        document-font-name = "${fonts.ui.name}   ${toString fonts.size}";
        monospace-font-name = "${fonts.mono.name} ${toString fonts.size}";
      };

      "org/gnome/desktop/peripherals/mouse" = {
        accel-profile = "flat";
      };

      "org/gnome/desktop/peripherals/touchpad" = {
        accel-profile = "flat";
        two-finger-scrolling-enabled = true;
      };

      "org/gnome/desktop/search-providers" = {
        disabled = ["org.gnome.Contacts.desktop" "org.gnome.seahorse.Application.desktop" "org.gnome.Characters.desktop" "org.gnome.clocks.desktop"];
        sort-order = ["org.gnome.Documents.desktop" "org.gnome.Nautilus.desktop" "org.gnome.Settings.desktop" "org.gnome.Calculator.desktop" "org.gnome.Calendar.desktop" "org.gnome.Epiphany.desktop" "org.gnome.Characters.desktop" "org.gnome.clocks.desktop" "org.gnome.Contacts.desktop" "org.gnome.seahorse.Application.desktop" "org.gnome.Weather.desktop"];
      };

      "org/gnome/desktop/wm/keybindings" = {
        close = ["<Super>q"];
        maximize = mkEmptyArray type.string;
        unmaximize = mkEmptyArray type.string;
      };

      "org/gnome/desktop/wm/preferences" = {
        button-layout = "appmenu:minimize,close";
        focus-mode = "sloppy";
      };

      "org/gnome/mutter" = {
        dynamic-workspaces = true;
        edge-tiling = false;
        experimental-features = ["scale-monitor-framebuffer" "variable-refresh-rate" "xwayland-native-scaling"];
        workspaces-only-on-primary = true;
      };

      "org/gnome/mutter/keybindings" = {
        toggle-tiled-left = mkEmptyArray type.string;
        toggle-tiled-right = mkEmptyArray type.string;
      };

      "org/gnome/nautilus/list-view" = {
        use-tree-view = true;
      };

      "org/gnome/nautilus/preferences" = {
        date-time-format = "detailed";
        default-folder-viewer = "list-view";
        migrated-gtk-settings = true;
        search-filter-time-type = "last_modified";
      };

      "org/gnome/settings-daemon/plugins/color" = {
        night-light-schedule-automatic = false;
      };

      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = ["/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"];
        home = ["<Super>f"];
        www = ["<Super>b"];
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        binding = "<Super>t";
        command = "ghostty";
        name = "terminal";
      };

      "org/gnome/shell" = {
        disabled-extensions = mkEmptyArray type.string;
        enabled-extensions = ["clipboard-indicator@tudmotu.com" "blur-my-shell@aunetx" "dash-to-dock@micxgx.gmail.com" "caffeine@patapon.info" "appindicatorsupport@rgcjonas.gmail.com" "dash-to-panel@jderose9.github.com" "tilingshell@ferrarodomenico.com"];
        favorite-apps = ["org.gnome.Nautilus.desktop" "brave-browser.desktop" "dev.zed.Zed.desktop" "com.github.xournalpp.xournalpp.desktop" "spotify.desktop"];
        last-selected-power-profile = "power-saver";
        welcome-dialog-last-shown-version = "47.1";
      };

      "org/gnome/shell/extensions/caffeine" = {
        countdown-timer = mkInt32 0;
        indicator-position-max = mkInt32 1;
        show-notifications = false;
      };

      "org/gnome/shell/extensions/dash-to-panel" = {
        animate-app-switch = false;
        animate-window-launch = false;
        appicon-margin = mkInt32 4;
        dot-position = "BOTTOM";
        panel-anchors = ''
          {"unknown-unknown":"MIDDLE"}
        '';
        panel-element-positions = ''
          {"unknown-unknown":[{"element":"activitiesButton","visible":true,"position":"stackedTL"},{"element":"showAppsButton","visible":true,"position":"stackedTL"},{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"stackedBR"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":true,"position":"stackedBR"}]}
        '';
        panel-sizes = ''
          {"unknown-unknown":32}
        '';
        prefs-opened = false;
        stockgs-keep-dash = true;
      };

      "org/gnome/shell/keybindings" = {
        screenshot = ["Print"];
        show-screenshot-ui = ["<Shift><Super>s"];
      };

      "org/gnome/tweaks" = {
        show-extensions-notice = false;
      };
    };
  in {
    programs.dconf = {
      enable = true;
      profiles.user.databases = [{inherit settings;}];
    };
  };
}
