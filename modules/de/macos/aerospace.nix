{self, ...}: {
  flake.modules.darwin.aerospace = {lib, ...}: let
    mkGaps = keys: lib.genAttrs keys (_: 0);
    mkBindings = prefix: command:
      lib.range 1 9
      |> map (i: lib.nameValuePair "${prefix}-${toString i}" "${command} ${toString i}")
      |> builtins.listToAttrs;
  in {
    imports = [self.modules.darwin.skhd];
    services.aerospace = {
      enable = true;
      settings = {
        config-version = 2;
        accordion-padding = 10;
        after-startup-command = [];
        default-root-container-layout = "tiles";
        default-root-container-orientation = "auto";
        enable-normalization-flatten-containers = true;
        enable-normalization-opposite-orientation-for-nested-containers = true;
        gaps = {
          inner = mkGaps ["horizontal" "vertical"];
          outer = mkGaps ["left" "right" "top" "bottom"];
        };
        key-mapping.preset = "qwerty";
        persistent-workspaces = ["1" "2" "3" "4" "5" "6" "7" "8" "9"];
        mode.main.binding =
          {
            ctrl-left = "focus left";
            ctrl-down = "focus down";
            ctrl-up = "focus up";
            ctrl-right = "focus right";
            ctrl-equal = "resize smart +50";
            ctrl-minus = "resize smart -50";
            ctrl-shift-left = "move left";
            ctrl-shift-down = "move down";
            ctrl-shift-up = "move up";
            ctrl-shift-right = "move right";
            ctrl-comma = "layout accordion horizontal vertical";
            ctrl-slash = "layout tiles horizontal vertical";
          }
          // (mkBindings "ctrl" "workspace")
          // (mkBindings "ctrl-shift" "move-node-to-workspace --focus-follows-window");
        on-focused-monitor-changed = ["move-mouse monitor-lazy-center"];
        on-window-detected = [
          {
            "if".app-id = "com.mitchellh.ghostty";
            run = ["layout tiling"];
          }
        ];
        start-at-login = false;
      };
    };
  };
}
