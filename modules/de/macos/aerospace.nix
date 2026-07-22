{self, ...}: {
  flake.modules.homeManager.aerospace = {lib, ...}: let
    mkGaps = keys: lib.genAttrs keys (_: 0);
    mkBindings = prefix: command:
      lib.range 1 9
      |> map (i: lib.nameValuePair "${prefix}-${toString i}" "${command} ${toString i}")
      |> builtins.listToAttrs;
  in {
    imports = [self.modules.homeManager.skhd];
    programs.aerospace = {
      enable = true;
      launchd.enable = true;
      settings = {
        config-version = 2;
        accordion-padding = 30;
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
            ctrl-alt-h = "focus left";
            ctrl-alt-j = "focus down";
            ctrl-alt-k = "focus up";
            ctrl-alt-l = "focus right";
            ctrl-alt-equal = "resize smart +50";
            ctrl-alt-minus = "resize smart -50";
            ctrl-alt-shift-h = "move left";
            ctrl-alt-shift-j = "move down";
            ctrl-alt-shift-k = "move up";
            ctrl-alt-shift-l = "move right";
            ctrl-alt-comma = "layout accordion horizontal vertical";
            ctrl-alt-slash = "layout tiles horizontal vertical";
          }
          // (mkBindings "ctrl-alt" "workspace")
          // (mkBindings "ctrl-alt-shift" "move-node-to-workspace --focus-follows-window");
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
