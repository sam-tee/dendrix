{
  self,
  inputs,
  ...
}: {
  flake-file.inputs = {
    noctalia = {
      url = "github:noctalia-dev/noctalia/cachix";
    };
  };
  flake.modules = {
    nixos.noctalia = _: {
      imports = [inputs.noctalia.nixosModules.default];
      programs.noctalia = {
        enable = true;
        recommendedServices.enable = true;
      };
    };
    homeManager.noctalia = {config, ...}: let
      bgDirFull = "${config.home.homeDirectory}/${bgDir}";
      bgDir = ".cache/noctalia/wallpapers";
    in {
      imports = [inputs.noctalia.homeModules.default];
      home.file = {
        "${bgDir}/bg.png".source = self.cosmetic.bgFile;
      };
      programs.noctalia = {
        enable = true;
        settings = {
          shell = {
            setup_wizard_enabled = false;
            corner_radius_scale = 0.0;
            clipboard_enabled = true;
            animation.enabled = false;
            shadow.alpha = 0.0;
            panel = {
              transparency_mode = "solid";
              borders = false;
              shadow = false;
            };
            launcher.categories = false;
            session.actions = [
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

          theme = {
            mode = "dark";
            source = "custom";
            custom_palette = "akhlus";
          };

          bar.main = {
            position = "left";
            thickness = 34;
            scale = 1.0;
            background_opacity = 1.0;
            reserve_space = false;
            capsule = false;
            border_width = 0.0;
            radius = 0;
            margin_ends = 0;
            margin_edge = 0;
            padding = 4;
            widget_spacing = 6;
            shadow = false;

            start = [
              "launcher"
              "clock-left"
            ];
            center = [
              "workspaces"
              "clock-center"
            ];
            end = [
              "tray"
              "volume"
              "network"
              "bluetooth"
              "battery"
              "control-center"
              "session"
            ];
          };

          widget = {
            launcher = {
              type = "launcher";
              glyph = "nix-snowflake";
            };

            clock-left = {
              type = "clock";
              format = "{:%d %b | %H:%M}";
              vertical_format = "{:%H %M - %d %m}";
            };

            clock-center = {
              type = "clock";
              format = "{:%d %b | %H:%M}";
              vertical_format = "{:%H %M - %d %m}";
            };

            workspaces = {
              type = "workspaces";
              hide_when_empty = false;
              display = "id";
              empty_color = "primary";
              focused_color = "primary";
              occupied_color = "secondary";
              pill_scale = 0.6;
            };
            tray = {
              type = "tray";
              drawer = true;
            };
            volume.type = "volume";
            network = {
              type = "network";
              show_label = false;
            };
            bluetooth = {
              type = "bluetooth";
              show_label = false;
            };
            battery = {
              type = "battery";
              display_mode = "graphic";
            };
            control-center = {
              type = "control-center";
              glyph = "settings-2";
            };
            session = {
              type = "session";
              glyph = "shutdown";
              color = "error";
            };
          };
          weather = {
            enabled = false;
            effects = false;
          };
          wallpaper = {
            enabled = true;
            transition_on_startup = false;
            directory = bgDirFull;
            fill_mode = "stretch";
          };
          dock.enabled = false;
          audio.enable_sounds = false;
          idle.behavior = {
            lock = {
              enabled = true;
              timeout = 300;
              command = "noctalia:session lock";
            };
            screen-off = {
              enabled = true;
              timeout = 299;
              command = "noctalia:dpms-off";
              resume_command = "noctalia:dpms-on";
            };
            suspend = {
              enabled = true;
              timeout = 600;
              command = "noctalia:session suspend";
            };
          };
          lockscreen.fingerprint = true;
        };
      };
    };
  };
}
