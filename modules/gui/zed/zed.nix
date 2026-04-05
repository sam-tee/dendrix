{self, ...}: let
  inherit (self.cosmetic) theme fonts;
  userTheme = theme.attrs;
in {
  flake.modules.homeManager.zed = _: {
    programs.zed-editor = {
      enable = true;
      installRemoteServer = true;
      themes.${userTheme.name} = import ./_theme.nix userTheme;
      userSettings = {
        agent.dock = "left";
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
        edit_predictions.mode = "subtle";
        file_types.Markdown = ["qmd"];
        hover_popover_delay = 200;
        inlay_hints.enabled = true;
        languages = {
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
        lsp = {
          nixd.settings.options = let
            flake = "(builtins.getFlake github:sam-tee/nixd-hosts)";
            options = system: "${flake}.${system}.lsp.options";
          in {
            darwin.expr = options "darwinConfigurations";
            home.expr = options "homeConfigurations";
            nixos.expr = options "nixosConfigurations";
            fp.expr = "${flake}.debug.options";
            fp2.expr = "${flake}.currentSystem.options";
          };
        };
        notification_panel.dock = "left";
        project_panel = {
          dock = "right";
          entry_spacing = "standard";
        };
        session.trust_all_worktrees = true;
        show_edit_predictions = false;
        theme = "${userTheme.name}";
      };
    };
  };
}
