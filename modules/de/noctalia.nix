{
  self,
  inputs,
  ...
}: {
  flake-file.inputs = {
    noctalia = {
      url = "github:noctalia-dev/noctalia";
    };
  };
  flake.modules = {
    nixos.noctalia = {pkgs, ...}: {
      nix.settings = {
        extra-substituters = ["https://noctalia.cachix.org"];
        extra-trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];
      };
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
      };
      services = {
        tuned.enable = true;
        upower.enable = true;
      };
      environment.systemPackages = [inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default];
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
              launcher_categories = false;
            };
          };

          theme = {
            mode = "dark";
            source = "builtin";
            builtin = "Noctalia";
          };

          bar.main = {
            position = "left";
            background_opacity = 1.0;
            reserve_space = false;
            capsule = false;
            shadow = false;
            margin_h = 0;
            margin_v = 0;
            padding = 6;
            widget_spacing = 4;
            scale = 0.85;
            start = ["launcher" "workspaces"];
            center = ["clock"];
            end = ["tray" "volume" "battery" "power_profile" "control-center" "session"];
          };

          widget = {
            clock = {
              format = "{:%H:%M\\n%d %b}";
              vertical_format = "{:%H\\n%M\\n%d\\n%m}";
            };
            workspaces = {
              display = "id";
              empty_color = "surface_variant";
              focused_color = "primary";
              occupied_color = "secondary";
              hide_when_empty = false;
              pill_scale = 0.6;
            };
            battery = {
              display_mode = "graphic";
              show_label = false;
            };
            "control-center".glyph = "settings-2";
          };

          control_center.shortcuts = [
            {type = "wifi";}
            {type = "bluetooth";}
            {type = "wallpaper";}
            {type = "session";}
          ];

          wallpaper = {
            enabled = true;
            transition_on_startup = false;
            directory = bgDirFull;
            fill_mode = "stretch";
            default.path = "${bgDirFull}/bg.png";
          };

          weather = {
            enabled = false;
            effects = false;
          };

          dock.enabled = false;

          audio = {
            enable_sounds = false;
          };

          idle.behavior = {
            lock = {
              enabled = true;
              timeout = 300;
              command = "noctalia:session lock";
            };
            "screen-off" = {
              enabled = true;
              timeout = 299;
              command = "noctalia:dpms-off";
              resume_command = "noctalia:dpms-on";
            };
            suspend = {
              enabled = true;
              timeout = 600;
              command = "systemctl suspend";
            };
          };
        };
      };
    };
  };
}
