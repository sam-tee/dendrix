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
      };
    };
  };
}
