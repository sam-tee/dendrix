let
  alias = {
    "la" = "ls -a";
    "lt" = "eza --tree --level=2 --long --git";
    "lta" = "lt -a";
    "py" = "python3";
    ".." = "cd ..";
    "..." = "cd ../..";
  };
in {
  flake.modules.nixos.cli = {
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

  flake.modules.darwin.cli = {
    programs.zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableSyntaxHighlighting = true;
    };
  };

  flake.modules.homeManager.cli = {
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
}
