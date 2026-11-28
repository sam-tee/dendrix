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
    inherit (lib) concatLists concatStringsSep genAttrs getExe mapAttrsToList nameValuePair optionalAttrs range;
    aerospace = getExe config.services.aerospace.package;
    super = concatStringsSep "-" config.keybinds.super;
  in {
    imports = [inputs.aeroswipe.darwinModules.default];
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
            "${super}-h" = "focus left";
            "${super}-j" = "focus down";
            "${super}-k" = "focus up";
            "${super}-l" = "focus right";
            "${super}-equal" = "resize smart +50";
            "${super}-minus" = "resize smart -50";
            "${super}-shift-h" = "move left";
            "${super}-shift-j" = "move down";
            "${super}-shift-k" = "move up";
            "${super}-shift-l" = "move right";
            "${super}-comma" = "layout accordion horizontal vertical";
            "${super}-slash" = "layout tiles horizontal vertical";
            "${super}-f" = "fullscreen";
            "${super}-v" = "layout floating tiling";
          }
          // (mkBindings "ctrl" "workspace")
          // (mkBindings "ctrl-shift" "move-node-to-workspace --focus-follows-window");
        on-focused-monitor-changed = ["move-mouse monitor-lazy-center"];
        on-focus-changed = ["move-mouse window-lazy-center"];
        on-window-detected =
          [
            {
              "if".app-id = "com.mitchellh.ghostty";
              check-further-callbacks = true;
              run = ["layout tiling"];
            }
          ]
          ++ (
            self.workspaceApps
            |> mapAttrsToList (workspace:
              map ({
                bundleId,
                titleRegex ? null,
              }: {
                "if" = {app-id = bundleId;} // optionalAttrs (titleRegex != null) {window-title-regex-substring = titleRegex;};
                run = ["move-node-to-workspace ${workspace}"];
              }))
            |> concatLists
          );
      };
    };
  };
}
