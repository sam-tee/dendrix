let
  alias = {
    "ls" = "eza --icons auto -la --group-directories-first";
    "lt" = "ls --tree --level=2";
    "ltt" = "ls --tree";
    "py" = "python3";
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    "md" = "mkdir -p";
    "-" = "cd -";
  };
in {
  flake.modules = {
    nixos.cli = _: {
      programs = {
        zsh = {
          enable = true;
          autosuggestions.enable = true;
          shellAliases = alias;
          syntaxHighlighting.enable = true;
          histFile = "$XDG_CONFIG_DIR/zsh/.zsh_history";
        };
        bash = {
          enable = true;
          shellAliases = alias;
        };
      };
    };
    homeManager.cli = {config, ...}: {
      programs = {
        zsh = {
          enable = true;
          history = {
            size = 10000;
            save = 10000;
            ignoreAllDups = true;
          };
          autosuggestion.enable = true;
          shellAliases = alias;
          syntaxHighlighting.enable = true;
          dotDir = "${config.xdg.configHome}/zsh";
        };
        bash = {
          enable = true;
          shellAliases = alias;
        };
      };
    };
  };
}
