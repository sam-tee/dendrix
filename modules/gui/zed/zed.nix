{
  lib,
  self,
  ...
}: let
  inherit (self.cosmetic) theme fonts;
  inherit (theme) attrs defaultVariant;
  mkJson = attrs: {
    generator = lib.generators.toJSON {};
    value = attrs;
  };
in {
  flake.modules.hjem.zed = _: {
    xdg.config.files =
      (["light" "dark"]
        |> map (variant: {
          name = "zed/themes/${attrs.name}-${variant}.json";
          value = mkJson (import ./_theme.nix attrs variant);
        })
        |> builtins.listToAttrs)
      // {
        "zed/settings.json" = mkJson {
          agent = {
            dock = "right";
            sidebar_side = "right";
            tool_permissions.default = "allow";
            sanbox_permissions = {
              allow_unsandboxed = false;
              allow_fs_write_all = true;
              allow_all_hosts = true;
            };
          };
          agent_servers = {
            cursor.type = "registry";
            opencode.type = "registry";
          };
          auto_install_extensions = {
            color-highlight = true;
            html = true;
            latex = true;
            log = true;
            nix = true;
            pylsp = true;
            rainbow-csv = true;
            toml = true;
          };
          auto_update = false;
          buffer_font_family = fonts.mono.name;
          buffer_font_size = fonts.size * 4 / 3;
          ui_font_family = fonts.ui.name;
          ui_font_size = fonts.size * 4 / 3;
          buffer_line_height.custom = 1.5;
          cli_default_open_behavior = "new_window";
          diagnostics.inline.enabled = true;
          edit_predictions.mode = "subtle";
          focus_follows_mouse = {
            enabled = true;
            debounce_ms = 150;
          };
          gutter = {
            bookmarks = false;
            breakpoints = false;
            runnables = false;
          };
          hover_popover_delay = 150;
          indent_guides.active_line_width = 3;
          inlay_hints.enabled = true;
          languages = {
            LaTeX = {
              soft_wrap = "bounded";
              preferred_line_length = 80;
            };
            Nix = {
              format_on_save = "on";
              formatter.external = {
                command = "alejandra";
                arguments = ["--quiet" "--"];
              };
              language_servers = ["nixd"];
              tab_size = 2;
            };
            Python = {
              format_on_save = "on";
              formatter = [
                {code_action = "source.organizeImports.ruff";}
                {language_server.name = "ruff";}
              ];
              language_servers = ["ty" "ruff"];
            };
          };
          project_panel = {
            auto_reveal_entries = false;
            dock = "right";
            entry_spacing = "standard";
            hide_root = true;
          };
          scrollbar.show = "system";
          scroll_beyond_last_line = "vertical_scroll_margin";
          show_edit_predictions = false;
          tab_bar = {
            show = true;
            show_nav_history_buttons = false;
            show_tab_bar_buttons = false;
          };
          tabs = {
            activate_on_close = "neighbour";
            git_status = true;
            show_close_button = "always";
          };
          theme = "${attrs.name}-${defaultVariant}";
          titlebar = {
            show_onboarding_banner = false;
            show_sign_in = false;
          };
          toolbar = {
            agent_review = false;
            breadcrumbs = false;
            quick_actions = false;
            selections_menu = false;
          };
          use_smartcase_search = true;
          vertical_scroll_margin = 5.0;
          vim = {
            cursor_shape.visual = "hollow";
            toggle_relative_line_numbers = true;
            use_smartcase_find = true;
          };
          vim_mode = true;
          which_key.enabled = true;
        };
      };
  };
}
