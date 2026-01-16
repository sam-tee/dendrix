{
  flake.modules.darwin.aerospace = {lib, ...}: {
    services.aerospace = {
      enable = true;
      settings = {
        accordion-padding = 30;
        after-startup-command = [];
        default-root-container-layout = "tiles";
        default-root-container-orientation = "auto";
        enable-normalization-flatten-containers = true;
        enable-normalization-opposite-orientation-for-nested-containers = true;
        gaps = let
          mkGaps = keys: lib.genAttrs keys (name: "0");
        in {
          inner = mkGaps ["horizontal" "vertical"];
          outer = mkGaps ["left" "right" "top" "bottom"];
        };
        key-mapping.preset = "qwerty";
        mode.main.binding = let
          mkBindings = prefix: command:
            builtins.listToAttrs (map (i: {
              name = "${prefix}-${toString i}";
              value = "${command} ${toString i}";
            }) [1 2 3 4 5 6 7 8 9]);
        in
          {
            ctrl-h = "focus left";
            ctrl-j = "focus down";
            ctrl-k = "focus up";
            ctrl-l = "focus right";
            ctrl-equal = "resize smart +50";
            ctrl-minus = "resize smart -50";
            ctrl-shift-h = "move left";
            ctrl-shift-j = "move down";
            ctrl-shift-k = "move up";
            ctrl-shift-l = "move right";
            ctrl-comma = "layout accordion horizontal vertical";
            ctrl-slash = "layout tiles horizontal vertical";
          }
          // (mkBindings "ctrl" "workspace")
          // (mkBindings "ctrl-shift" "move-node-to-workspace");
        on-focused-monitor-changed = ["move-mouse monitor-lazy-center"];
        start-at-login = false;
      };
    };
  };
}
