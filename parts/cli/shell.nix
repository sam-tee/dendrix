let
  alias = {
    "ls" = "eza -lh --group-directories-first";
    "la" = "ls -a";
    "lt" = "eza --tree --level=2 --long --git";
    "lta" = "lt -a";
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

    darwin.cli = {
      programs.zsh = _: {
        enable = true;
        enableAutosuggestions = true;
        enableSyntaxHighlighting = true;
      };
    };

    homeManager.cli = _: {
      programs = {
        zsh = {
          enable = true;
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
