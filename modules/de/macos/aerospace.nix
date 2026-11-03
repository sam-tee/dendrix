{
  moduleWithSystem,
  self,
  ...
}: {
  flake.modules.darwin.aerospace = moduleWithSystem ({inputs', ...}: {
    config,
    lib,
    pkgs,
    ...
  }: let
    aerospace = lib.getExe config.services.aerospace.package;
    gesturesConfig = (pkgs.formats.toml {}).generate "aerospace-gestures.toml" {
      bindings =
        lib.mapAttrsToList (direction: command: {
          fingers = 3;
          inherit direction command;
        }) {
          up = [aerospace "workspace" "--no-stdin" "next"];
          down = [aerospace "workspace" "--no-stdin" "prev"];
          left = [aerospace "scroll" "right"];
          right = [aerospace "scroll" "left"];
        };
    };
  in {
    imports = [self.modules.darwin.skhd];
    launchd.user.agents.aerospace-gestures = {
      command = "${lib.getExe inputs'.aerospace-gestures.packages.default} run ${gesturesConfig}";
      serviceConfig = {
        KeepAlive = true;
        RunAtLoad = true;
      };
    };
    services.aerospace = {
      enable = true;
      settings = {
        config-version = 2;
        accordion-padding = 5;
        after-startup-command = [];
        default-root-container-layout = "tiles";
        default-root-container-orientation = "auto";
        enable-normalization-flatten-containers = true;
        enable-normalization-opposite-orientation-for-nested-containers = true;
        gaps = let
          mkGaps = keys: lib.genAttrs keys (_: 0);
        in {
          inner = mkGaps ["horizontal" "vertical"];
          outer = mkGaps ["left" "right" "top" "bottom"];
        };
        key-mapping.preset = "qwerty";
        persistent-workspaces = ["1" "2" "3" "4" "5" "6" "7" "8" "9"];
        mode.main.binding = let
          mkBindings = prefix: command:
            lib.range 1 9
            |> map (i: lib.nameValuePair "${prefix}-${toString i}" "${command} ${toString i}")
            |> builtins.listToAttrs;
        in
          {
            ctrl-cmd-h = "focus left";
            ctrl-cmd-j = "focus down";
            ctrl-cmd-k = "focus up";
            ctrl-cmd-l = "focus right";
            ctrl-cmd-equal = "resize smart +50";
            ctrl-cmd-minus = "resize smart -50";
            ctrl-cmd-shift-h = "move left";
            ctrl-cmd-shift-j = "move down";
            ctrl-cmd-shift-k = "move up";
            ctrl-cmd-shift-l = "move right";
            ctrl-cmd-comma = "layout accordion horizontal vertical";
            ctrl-cmd-slash = "layout tiles horizontal vertical";
            ctrl-cmd-f = "fullscreen";
            ctrl-cmd-v = "layout floating tiling";
          }
          // (mkBindings "ctrl" "workspace")
          // (mkBindings "ctrl-shift" "move-node-to-workspace --focus-follows-window");
        on-focused-monitor-changed = ["move-mouse monitor-lazy-center"];
        on-focus-changed = ["move-mouse window-lazy-center"];
        on-window-detected = [
          {
            "if".app-id = "com.mitchellh.ghostty";
            run = ["layout tiling"];
          }
        ];
      };
    };
  });
}
