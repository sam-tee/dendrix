{
  agent.dock = "right";
  auto_install_extensions = {
    html = true;
    latex = true;
    log = true;
    nix = true;
    pylsp = true;
    rainbow-csv = true;
    toml = true;
  };
  base_keymap = "VSCode";
  buffer_font_family = "Lilex Nerd Font Mono";
  buffer_font_size = 14;
  edit_predictions = {
    copilot = {
      enterprise_uri = null;
      proxy = null;
      proxy_no_verify = null;
    };
    enabled_in_text_threads = false;
    mode = "subtle";
  };
  features.edit_prediction_provider = "zed";
  file_types = {Markdown = ["qmd"];};
  gutter = {
    breakpoints = true;
    folds = true;
    line_numbers = true;
    runnables = true;
  };
  icon_theme = "Zed (Default)";
  inlay_hints = {
    edit_debounce_ms = 700;
    enabled = true;
    scroll_debounce_ms = 50;
    show_background = false;
    show_other_hints = false;
    show_parameter_hints = true;
    show_type_hints = true;
    show_value_hints = true;
    toggle_on_modifiers_press = {
      alt = false;
      control = false;
      function = false;
      platform = false;
      shift = false;
    };
  };
  languages = {
    Nix = {
      format_on_save = "off";
      language_servers = ["nixd" "!nil"];
      tab_size = 2;
    };
    Python = {
      format_on_save = "on";
      formatter = [{code_action = "source.organizeImports.ruff";} {language_server = {name = "ruff";};}];
      language_servers = ["pylsp" "!pyright" "ruff"];
    };
  };
  load_direnv = "shell_hook";
  lsp = {
    basedpyright = {
      settings.python.analysis.typeCheckingMode = "standard";
    };
    nixd = {
      settings = {
        formatting = {command = ["alejandra"];};
        options = {
          darwin = {expr = "(builtins.getFlake github:akhlus/nix).darwinConfigurations.test.options";};
          home = {expr = "(builtins.getFlake github:akhlus/nix).homeConfigurations.test.options";};
          nixos = {expr = "(builtins.getFlake github:akhlus/nix).nixosConfigurations.test.options";};
        };
      };
    };
  };
  notification_panel = {dock = "left";};
  outline_panel = {button = false;};
  project_panel = {
    button = true;
    dock = "right";
  };
  scrollbar = {show = "auto";};
  show_edit_predictions = false;
  soft_wrap = "none";
  ssh_connections = [
    {
      host = "u410";
      projects = [{paths = ["/home/u410/Code"];}];
    }
  ];
  tab_bar = {show = false;};
  terminal = {
    dock = "bottom";
    font_family = "Lilex Nerd Font Mono";
    working_directory = "current_project_directory";
  };
  theme = "akhlus";
  ui_font_family = "IBM Plex Sans";
  ui_font_size = 14;
}
