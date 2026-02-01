{
  flake.modules.homeManager.gnome = {
    config,
    lib,
    username,
    ...
  }: let
    bg = config.cosmetic.backgroundPath;
  in {
    dconf.settings = with lib.hm.gvariant; {
      "org/gnome/TextEditor" = {
        restore-session = false;
      };

      "org/gnome/desktop/background" = {
        color-shading-type = "solid";
        picture-options = "zoom";
        picture-uri = "file:///home/${username}/${bg}";
        picture-uri-dark = "file:///home/${username}/${bg}";
      };

      "org/gnome/desktop/interface" = {
        accent-color = "teal";
        color-scheme = "prefer-dark";
        enable-animations = false;
        enable-hot-corners = false;
      };

      "org/gnome/desktop/peripherals/mouse" = {
        accel-profile = "flat";
      };

      "org/gnome/desktop/peripherals/touchpad" = {
        accel-profile = "flat";
        two-finger-scrolling-enabled = true;
      };

      "org/gnome/desktop/screensaver" = {
        color-shading-type = "solid";
        picture-options = "zoom";
        picture-uri = "file:///home/${username}/${bg}";
        picture-uri-dark = "file:///home/${username}/${bg}";
      };

      "org/gnome/desktop/search-providers" = {
        disabled = ["org.gnome.Contacts.desktop" "org.gnome.seahorse.Application.desktop" "org.gnome.Characters.desktop" "org.gnome.clocks.desktop"];
        sort-order = ["org.gnome.Documents.desktop" "org.gnome.Nautilus.desktop" "org.gnome.Settings.desktop" "org.gnome.Calculator.desktop" "org.gnome.Calendar.desktop" "org.gnome.Epiphany.desktop" "org.gnome.Characters.desktop" "org.gnome.clocks.desktop" "org.gnome.Contacts.desktop" "org.gnome.seahorse.Application.desktop" "org.gnome.Weather.desktop"];
      };

      "org/gnome/desktop/wm/keybindings" = {
        close = ["<Super>q"];
        maximize = [];
        unmaximize = [];
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
        toggle-tiled-left = [];
        toggle-tiled-right = [];
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
        disabled-extensions = [];
        enabled-extensions = ["clipboard-indicator@tudmotu.com" "blur-my-shell@aunetx" "dash-to-dock@micxgx.gmail.com" "caffeine@patapon.info" "appindicatorsupport@rgcjonas.gmail.com" "dash-to-panel@jderose9.github.com" "tilingshell@ferrarodomenico.com"];
        favorite-apps = ["org.gnome.Nautilus.desktop" "brave-browser.desktop" "dev.zed.Zed.desktop" "com.github.xournalpp.xournalpp.desktop" "spotify.desktop"];
        last-selected-power-profile = "power-saver";
        welcome-dialog-last-shown-version = "47.1";
      };

      "org/gnome/shell/extensions/caffeine" = {
        countdown-timer = 0;
        indicator-position-max = 1;
        show-notifications = false;
      };

      "org/gnome/shell/extensions/dash-to-dock" = {
        autohide-in-fullscreen = true;
        background-opacity = 0.8;
        custom-theme-shrink = true;
        dash-max-icon-size = 40;
        dock-position = "BOTTOM";
        height-fraction = 0.9;
        hot-keys = false;
        intellihide-mode = "FOCUS_APPLICATION_WINDOWS";
        multi-monitor = true;
        preferred-monitor = -2;
        running-indicator-style = "DOTS";
        show-icons-notifications-counter = false;
        show-mounts = false;
        show-show-apps-button = true;
        show-trash = false;
      };

      "org/gnome/shell/extensions/dash-to-panel" = {
        animate-app-switch = false;
        animate-window-launch = false;
        appicon-margin = 4;
        dot-position = "BOTTOM";
        intellihide = true;
        intellihide-behaviour = "ALL_WINDOWS";
        intellihide-hide-from-windows = true;
        prefs-opened = false;
        stockgs-keep-dash = true;
      };

      "org/gnome/shell/extensions/tilingshell" = {
        enable-window-border = false;
        inner-gaps = mkUint32 2;
        last-version-name-installed = "16.4";
        layouts-json = "[{\"id\":\"Layout 2\",\"tiles\":[{\"x\":0,\"y\":0,\"width\":0.24973958333333332,\"height\":0.24861111111111112,\"groups\":[1,4]},{\"x\":0.24973958333333332,\"y\":0,\"width\":0.5005208333333333,\"height\":0.5,\"groups\":[2,3,1]},{\"x\":0.7502604166666667,\"y\":0,\"width\":0.24973958333333335,\"height\":1,\"groups\":[2]},{\"x\":0.24973958333333332,\"y\":0.5,\"width\":0.5005208333333333,\"height\":0.5,\"groups\":[3,2,1]},{\"x\":0,\"y\":0.24861111111111112,\"width\":0.24973958333333332,\"height\":0.751388888888889,\"groups\":[4,1]}]},{\"id\":\"483365\",\"tiles\":[{\"x\":0,\"y\":0,\"width\":0.5,\"height\":0.5,\"groups\":[1,2]},{\"x\":0.5,\"y\":0,\"width\":0.49999999999999994,\"height\":0.5,\"groups\":[3,1]},{\"x\":0,\"y\":0.5,\"width\":0.5,\"height\":0.5,\"groups\":[2,1]},{\"x\":0.5,\"y\":0.5,\"width\":0.49999999999999994,\"height\":0.49999999999999994,\"groups\":[3,1]}]},{\"id\":\"1186829\",\"tiles\":[{\"x\":0,\"y\":0,\"width\":0.24973958333333332,\"height\":0.5,\"groups\":[1,5]},{\"x\":0.24973958333333332,\"y\":0,\"width\":0.5005208333333333,\"height\":0.5,\"groups\":[2,3,1]},{\"x\":0.7502604166666667,\"y\":0,\"width\":0.2497395833333329,\"height\":0.5,\"groups\":[4,2]},{\"x\":0.24973958333333332,\"y\":0.5,\"width\":0.5005208333333333,\"height\":0.5,\"groups\":[3,2,1]},{\"x\":0.7502604166666667,\"y\":0.5,\"width\":0.2497395833333329,\"height\":0.49999999999999994,\"groups\":[4,2]},{\"x\":0,\"y\":0.5,\"width\":0.24973958333333332,\"height\":0.5,\"groups\":[5,1]}]}]";
        outer-gaps = mkUint32 2;
        overridden-settings = "{\"org.gnome.mutter.keybindings\":{\"toggle-tiled-right\":\"['<Super>Right']\",\"toggle-tiled-left\":\"['<Super>Left']\"},\"org.gnome.desktop.wm.keybindings\":{\"maximize\":\"['<Super>Up']\",\"unmaximize\":\"['<Super>Down', '<Alt>F5']\"},\"org.gnome.mutter\":{\"edge-tiling\":\"true\"}}";
        selected-layouts = [["Layout 2"] ["Layout 2"]];
        snap-assistant-animation-time = mkUint32 0;
        tile-preview-animation-time = mkUint32 0;
        top-edge-maximize = true;
        window-border-color = "rgb(129,61,156)";
      };

      "org/gnome/shell/keybindings" = {
        screenshot = ["Print"];
        show-screenshot-ui = ["<Shift><Super>s"];
      };

      "org/gnome/tweaks" = {
        show-extensions-notice = false;
      };
    };
  };
}
