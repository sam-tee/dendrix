let
  alias = {
    "l" = "eza --icons auto -l --group-directories-first";
    "ls" = "l -a";
    "lt" = "l -aT --level=2";
    "ltt" = "l -T";
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
      environment.variables.ZDOTDIR = "$HOME/.config/zsh";
      programs.zsh = {
        enable = true;
        histFile = "$HOME/.config/zsh/history";
        histSize = 10000;
        interactiveShellInit = ''
          eval "$(atuin init zsh)"
          bindkey ' ' magic-space
        '';
        autosuggestions.enable = true;
        shellAliases = alias;
        syntaxHighlighting.enable = true;
      };
    };
    homeManager.cli = {
      config,
      lib,
      ...
    }: {
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
          initContent = lib.mkAfter ''
            jsonfmt() {
              if [ -z "$1" ]; then
                echo "Usage: formatjson <filename.json>"
                return 1
              fi

              jq . "$1" > "$1.tmp" && mv "$1.tmp" "$1"
            }
            bindkey ' ' magic-space
            autoload -Uz _nix
            compdef -d nix
            compdef _nix nix
          '';
        };
        bash = {
          enable = true;
          shellAliases = alias;
        };
        carapace = {
          enable = true;
          ignoreCase = true;
        };
      };
    };
  };
}
