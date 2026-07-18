{self, ...}: let
  inherit (self.cosmetic) theme fonts;
  inherit (theme) attrs defaultVariant;
in {
  flake.modules.homeManager.zed = _: {
    programs.zed-editor = {
      enable = true;
      installRemoteServer = true;
      themes =
        ["light" "dark"]
        |> map (variant: {
          name = "${attrs.name}-${variant}";
          value = import ./_theme.nix attrs variant;
        })
        |> builtins.listToAttrs;
      userSettings = {
        agent = {
          dock = "right";
          sidebar_side = "right";
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
        buffer_font_family = fonts.mono.name;
        buffer_font_size = fonts.size * 4 / 3;
        ui_font_family = fonts.ui.name;
        ui_font_size = fonts.size * 4 / 3;
        buffer_line_height.custom = 1.5;
        cli_default_open_behavior = "new_window";
        edit_predictions.mode = "subtle";
        file_types.Markdown = ["qmd"];
        hover_popover_delay = 200;
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
        session.trust_all_worktrees = true;
        show_edit_predictions = false;
        tabs.activate_on_close = "neighbour";
        theme = "${attrs.name}-${defaultVariant}";
        use_smartcase_search = true;
        vim_mode = true;
        vim = {
          toggle_relative_line_numbers = true;
          use_smartcase_find = true;
        };
        which_key.enabled = true;
      };
    };
  };
}
