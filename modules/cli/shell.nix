let
  alias = {
    "ls" = "eza -la --group-directories-first";
    "lt" = "ls --tree --level=2";
    "ltt" = "ls --tree";
    "py" = "python3";
    ".." = "cd ..";
    "..." = "cd ../..";
  };
in {
  flake.modules = {
    nixos.cli = _: {
      programs = {
        zsh = {
          enable = true;
          autosuggestions.enable = true;
          ohMyZsh.enable = true;
          shellAliases = alias;
          syntaxHighlighting.enable = true;
        };
        bash = {
          enable = true;
          shellAliases = alias;
        };
      };
    };

    darwin.cli = _: {
      programs.zsh = {
        enable = true;
        enableAutosuggestions = true;
        enableSyntaxHighlighting = true;
      };
    };

    homeManager.cli = _: {
      programs = {
        zsh = {
          enable = true;
          history.ignoreAllDups = true;
          autosuggestion.enable = true;
          oh-my-zsh.enable = true;
          shellAliases = alias;
          syntaxHighlighting.enable = true;
        };
        bash = {
          enable = true;
          shellAliases = alias;
        };
      };
    };
  };
}
