{
  self,
  lib,
  ...
}: let
  inherit (self.cosmetic.cursor) name pkgsName size;
  inherit (lib) mkDefault singleton;
in {
  flake.modules = {
    nixos.noctalia = {pkgs, ...}: {
      hjem.extraModules = singleton self.modules.hjem.noctalia;
      services.displayManager.noctalia-greeter = {
        enable = mkDefault true;
        settings = {
          cursor.size = size;
          keyboard.layout = "gb";
        };
        cursorTheme = {
          package = pkgsName pkgs;
          inherit name;
        };
      };
      programs.noctalia = {
        enable = true;
        recommendedServices.enable = true;
        systemd.enable = true;
      };
    };
    hjem.noctalia = {
      config,
      pkgs,
      ...
    }: let
      bgDir = "noctalia/wallpapers";
      bgDirFull = "${config.xdg.cache.directory}/${bgDir}";
      bgPath = "${bgDir}/bg.png";
      settings = {
        audio.enable_sounds = false;
        bar.main = {
          background_opacity = 1.0;
          border_width = 0.0;
          capsule = false;
          center = ["clock"];
          end = [
            "tray"
            "volume"
            "network"
            "bluetooth"
            "battery"
            "control-center"
            "session"
          ];
          font_family = "Inter";
          margin_ends = 0;
          margin_edge = 0;
          padding = 4;
          position = "top";
          radius = 0;
          reserve_space = false;
          scale = 1.0;
          shadow = false;
          smart_auto_hide = true;
          start = [
            "launcher"
            "workspaces"
          ];
          thickness = 34;
          widget_spacing = 6;
        };
        battery.warning_threshold = 15;
        calendar.enabled = true;
        control_center = {
          hidden_tabs = ["media" "system"];
          sidebar = "full";
        };
        dock.enabled = false;
        idle.behavior = {
          lock = {
            enabled = true;
            action = "lock";
            timeout = 180;
            command = "noctalia:session lock";
          };
          screen-off = {
            enabled = true;
            action = "screen_off";
            timeout = 300;
            command = "noctalia:dpms-off";
            resume_command = "noctalia:dpms-on";
          };
          suspend = {
            enabled = true;
            action = "lock_and_suspend";
            timeout = 600;
            command = "noctalia:session suspend";
          };
        };
        location.auto_locate = true;
        lockscreen.fingerprint = true;
        notification.layer = "overlay";
        osd = {
          position = "top-right";
          position_vertical = "top-right";
          kinds.media = false;
        };
        shell = {
          clipboard_enabled = true;
          corner_radius_scale = 0.0;
          font_family = "Inter";
          launch_apps_as_systemd_services = false;
          polkit_agent = true;
          screen_time_enabled = true;
          setup_wizard_enabled = false;
          animation.enabled = false;
          greeter_sync.auto_sync = true;
          launcher.categories = false;
          panel = {
            borders = false;
            open_near_click_session = true;
            shadow = false;
            transparency_mode = "solid";
          };
          screenshot.directory = "~/Downloads";
          session = {
            grid = true;
            actions = [
              {
                action = "lock";
                enabled = true;
                countdown_seconds = 0.0;
              }
              {
                action = "logout";
                enabled = true;
                countdown_seconds = 0.0;
              }
              {
                action = "suspend";
                enabled = true;
                countdown_seconds = 0.0;
              }
              {
                action = "reboot";
                enabled = true;
                countdown_seconds = 0.0;
              }
              {
                action = "shutdown";
                enabled = true;
                countdown_seconds = 0.0;
              }
            ];
          };
          shadow.alpha = 0.0;
        };
        system.monitor.enabled = false;
        theme = {
          custom_palette = "akhlus";
          mode = "dark";
          source = "custom";
        };
        wallpaper = {
          directory = bgDirFull;
          enabled = true;
          fill_mode = "stretch";
          transition_on_startup = false;
          default.path = bgPath;
          last.path = bgPath;
        };
        weather = {
          enabled = false;
          effects = false;
        };
        widget = {
          battery = {
            type = "battery";
            display_mode = "glyph";
          };
          bluetooth = {
            type = "bluetooth";
            show_label = false;
          };
          clock = {
            type = "clock";
            format = "{:%H:%M | %d/%m/%y}";
            vertical_format = "{:%H\n%M\n-\n%d\n%m\n%y}";
          };
          control-center = {
            type = "control-center";
            glyph = "settings-2";
          };
          launcher = {
            type = "launcher";
            glyph = "menu-2";
          };
          network = {
            type = "network";
            show_label = false;
          };
          session = {
            type = "session";
            glyph = "shutdown";
            color = "error";
          };
          tray = {
            type = "tray";
            drawer = true;
          };
          volume = {
            show_label = false;
            type = "volume";
          };
          workspaces = {
            label_source = "id";
            empty_color = "tertiary";
            focused_color = "primary";
            hide_when_empty = false;
            occupied_color = "secondary";
            pill_scale = 0.6;
            style = "minimal";
            type = "workspaces";
          };
        };
      };
    in {
      xdg.cache.files.${bgPath}.source = self.cosmetic.bgFile;
      xdg.config.files."noctalia/config.toml" = {
        generator = (pkgs.formats.toml {}).generate "config.toml";
        value = settings;
      };
    };
  };
}
