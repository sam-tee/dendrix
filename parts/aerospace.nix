{...}: {
  flake.modules.darwin.aerospace = {
    services.aerospace = {
      enable = true;
      settings = {
        accordion-padding = 30;
        after-startup-command = [];
        default-root-container-layout = "tiles";
        default-root-container-orientation = "auto";
        enable-normalization-flatten-containers = true;
        enable-normalization-opposite-orientation-for-nested-containers = true;
        gaps = {
          inner = {
            horizontal = 0;
            vertical = 0;
          };
          outer = {
            bottom = 0;
            left = 0;
            right = 0;
            top = 0;
          };
        };
        key-mapping = {preset = "qwerty";};
        mode = {
          main = {
            binding = {
              ctrl-1 = "workspace 1";
              ctrl-2 = "workspace 2";
              ctrl-3 = "workspace 3";
              ctrl-4 = "workspace 4";
              ctrl-5 = "workspace 5";
              ctrl-6 = "workspace 6";
              ctrl-7 = "workspace 7";
              ctrl-8 = "workspace 8";
              ctrl-9 = "workspace 9";
              ctrl-h = "focus left";
              ctrl-j = "focus down";
              ctrl-k = "focus up";
              ctrl-l = "focus right";
              ctrl-equal = "resize smart +50";
              ctrl-minus = "resize smart -50";
              ctrl-shift-1 = "move-node-to-workspace 1";
              ctrl-shift-2 = "move-node-to-workspace 2";
              ctrl-shift-3 = "move-node-to-workspace 3";
              ctrl-shift-4 = "move-node-to-workspace 4";
              ctrl-shift-5 = "move-node-to-workspace 5";
              ctrl-shift-6 = "move-node-to-workspace 6";
              ctrl-shift-7 = "move-node-to-workspace 7";
              ctrl-shift-8 = "move-node-to-workspace 8";
              ctrl-shift-9 = "move-node-to-workspace 9";
              ctrl-shift-h = "move left";
              ctrl-shift-j = "move down";
              ctrl-shift-k = "move up";
              ctrl-shift-l = "move right";
              ctrl-comma = "layout accordion horizontal vertical";
              ctrl-slash = "layout tiles horizontal vertical";
            };
          };
        };
        on-focused-monitor-changed = ["move-mouse monitor-lazy-center"];
        start-at-login = false;
      };
    };
  };
}
