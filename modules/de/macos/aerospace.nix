{
  inputs,
  self,
  ...
}: {
  flake.modules.darwin.aerospace = {
    config,
    lib,
    ...
  }: let
    inherit (lib) genAttrs getExe nameValuePair range;
    aerospace = getExe config.services.aerospace.package;
  in {
    imports = [
      inputs.aeroswipe.darwinModules.default
      self.modules.darwin.skhd
    ];
    services.aeroswipe = {
      enable = true;
      settings.commands = {
        up = [aerospace "workspace" "--no-stdin" "next"];
        down = [aerospace "workspace" "--no-stdin" "prev"];
        left = [aerospace "focus" "left"];
        right = [aerospace "focus" "right"];
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
          mkGaps = keys: genAttrs keys (_: 0);
        in {
          inner = mkGaps ["horizontal" "vertical"];
          outer = mkGaps ["left" "right" "top" "bottom"];
        };
        key-mapping.preset = "qwerty";
        persistent-workspaces = ["1" "2" "3" "4" "5" "6" "7" "8" "9"];
        mode.main.binding = let
          mkBindings = prefix: command:
            range 1 9
            |> map (i: nameValuePair "${prefix}-${toString i}" "${command} ${toString i}")
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
  };
}
