{
  inputs,
  self,
  ...
}: {
  flake.modules.darwin.paneru = {
    config,
    lib,
    ...
  }: let
    inherit (lib) concatLists concatStringsSep escapeRegex generators genAttrs mapAttrsToList nameValuePair optionalAttrs range toInt;
    super = concatStringsSep " + " config.keybinds.super;
    toLua = generators.toLua {};
    settings = {
      options = {
        focus_follows_mouse = true;
        mouse_follows_focus = true;
        preset_column_widths = [0.5];
        menubar_height = 0;
      };
      decorations.workspace_popup_status = false;
      swipe = {
        continuous = false;
        gesture.fingers_count = 3;
      };
      padding = genAttrs ["left" "right" "top" "bottom"] (_: 0);
      bindings = let
        mkBindings = prefix: command:
          range 1 9
          |> map (i: nameValuePair "${command} ${toString i}" "${prefix} - ${toString i}")
          |> builtins.listToAttrs;
      in
        {
          "window focus west" = "${super} - h";
          "window focus east" = "${super} - l";
          "window focus north" = "${super} - k";
          "window focus south" = "${super} - j";
          "window swap west" = "${super} + shift - h";
          "window swap east" = "${super} + shift - l";
          "window swap north" = "${super} + shift - k";
          "window swap south" = "${super} + shift - j";
          "window center" = "${super} - m";
          "window resize" = "${super} - r";
          "window fullwidth" = "${super} - f";
          "window manage" = "${super} - v";
          "window stack" = "${super} - period";
          "window unstack" = "${super} - comma";
          "window nextdisplay" = "${super} - tab";
          "window nextdisplaysend" = "${super} + shift - tab";
        }
        // (mkBindings "ctrl" "window virtualnum")
        // (mkBindings "ctrl + shift" "window virtualmovenum");
      windows.pip = {
        title = "Picture.*(in)?.*[Pp]icture";
        floating = true;
      };
    };
    workspaceRules =
      self.workspaceApps
      |> mapAttrsToList (workspace:
        map ({
          bundleId,
          titleRegex ? null,
        }: {
          workspace = toInt workspace;
          match =
            {
              bundle = "^${escapeRegex bundleId}$";
              subrole = "AXStandardWindow";
            }
            // optionalAttrs (titleRegex != null) {title = titleRegex;};
        }))
      |> concatLists;
  in {
    imports = [inputs.paneru.darwinModules.paneru];
    # A Lua config switches paneru's TOML config off entirely, so the settings live in paneru.setup
    services.paneru = {
      enable = true;
      config = ''
        paneru.setup(${toLua settings})

        local is_pip = paneru.match { title = ${toLua settings.windows.pip.title} }
        local workspace_rules = {}
        for _, rule in ipairs(${toLua workspaceRules}) do
          table.insert(workspace_rules, { workspace = rule.workspace, matches = paneru.match(rule.match) })
        end

        local function home_workspace(event)
          if is_pip(event) then
            return nil
          end
          for _, rule in ipairs(workspace_rules) do
            if rule.matches(event) then
              return rule.workspace
            end
          end
        end

        -- A sibling of the same app already here means the window is a native tab (paneru moves
        -- the whole tab group) or the app was moved here on purpose, so leave it be
        local function has_sibling(ws, event, workspace)
          for _, window in ipairs(ws:workspace_windows(workspace)) do
            if window.id ~= event.window_id and window.bundle_id == event.bundle_id then
              return true
            end
          end
          return false
        end

        -- Window ids outlive a paneru restart but get reused after a reboot, so a window
        -- only counts as already homed if its pid matches too
        paneru.on("window_spawned", function(event, ws)
          local workspace = home_workspace(event)
          if not workspace then
            return
          end
          local id = tostring(event.window_id)
          local already_homed = false
          paneru.state.mutate("homed_windows", function(homed)
            homed = homed or {}
            already_homed = homed[id] == event.pid
            homed[id] = event.pid
            return homed
          end)
          local current = ws:workspace_of(event.window_id) or ws:current()
          if already_homed or current == workspace or has_sibling(ws, event, current) then
            return
          end
          return ws:shift(event.window_id, workspace)
        end)

        paneru.on("window_destroyed", function(event)
          paneru.state.mutate("homed_windows", function(homed)
            if homed then
              homed[tostring(event.window_id)] = nil
            end
            return homed
          end)
        end)
      '';
    };
  };
}
