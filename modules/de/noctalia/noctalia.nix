{
  self,
  inputs,
  ...
}: {
  flake-file.inputs = {
    noctalia.url = "github:noctalia-dev/noctalia/cachix";
    noctalia-greeter.url = "github:noctalia-dev/noctalia-greeter";
  };
  flake.modules = {
    nixos.noctalia = _: {
      disabledModules = ["programs/wayland/noctalia.nix"];
      imports = [
        inputs.noctalia.nixosModules.default
        inputs.noctalia-greeter.nixosModules.default
      ];
      programs = {
        noctalia = {
          enable = true;
          recommendedServices.enable = true;
        };
        noctalia-greeter = {
          enable = true;
          greeter-args = "";
        };
      };
    };
    homeManager.noctalia = {config, ...}: let
      bgDirFull = "${config.home.homeDirectory}/${bgDir}";
      bgDir = ".cache/noctalia/wallpapers";
      bgPath = "${bgDir}/bg.png";
    in {
      imports = [inputs.noctalia.homeModules.default];
      home.file.${bgPath}.source = self.cosmetic.bgFile;
      programs.noctalia = {
        enable = true;
        settings = {
          audio.enable_sounds = false;
          bar.main = {
            background_opacity = 1.0;
            border_width = 0.0;
            capsule = false;
            center = ["workspaces"];
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
            position = "left";
            radius = 0;
            reserve_space = true;
            scale = 1.0;
            shadow = false;
            start = [
              "launcher"
              "clock"
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
              timeout = 300;
              command = "noctalia:session lock";
            };
            screen-off = {
              enabled = true;
              action = "screen_off";
              timeout = 299;
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
            polkit_agent = true;
            screen_time_enabled = true;
            settings_show_advancded = true;
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
            screenshot.directory = "~/Pictures/Screenshots/";
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
              format = "{:%d %b | %H:%M}";
              vertical_format = "{:%H\n%M\n-\n%d\n%m}";
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
              display = "id";
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
      };
    };
  };
}
