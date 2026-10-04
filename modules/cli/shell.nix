{self, ...}: {
  flake.modules = {
    generic.zsh = {
      lib,
      pkgs,
      ...
    }: let
      shellAliases = {
        "l" = "eza --icons auto -l --group-directories-first";
        "ls" = "l -a";
        "lt" = "l -aT --level=2";
        "ltt" = "l -T";
        "lg" = "lazygit";
        "py" = "python3";
        "cat" = "bat --paging=never";
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
      };
      strShellAliases =
        shellAliases
        |> lib.filterAttrs (k: v: v != null)
        |> lib.mapAttrsToList (k: v: "alias -- ${k}=${lib.escapeShellArg v}")
        |> builtins.concatStringsSep "\n";
      fzfTheme = "--color=base16";
    in {
      environment = {
        variables = {
          XDG_CACHE_HOME = "$HOME/.cache";
          XDG_CONFIG_HOME = "$HOME/.config";
          XDG_DATA_HOME = "$HOME/.local/share";
          XDG_STATE_HOME = "$HOME/.local/state";
          ZDOTDIR = "$HOME/.config/zsh";
          EDITOR = "nvim";
          VISUAL = "nvim";
          PAGER = "less";
          LESS = "-FRX --quit-if-one-screen";
          LESSHISTFILE = "$HOME/.local/state/less/history";
          MANPAGER = "delta -pman";
          DELTA_PAGER = "less --raw-control-chars";
          FZF_DEFAULT_OPTS = fzfTheme;
          FZF_CTRL_R_COMMAND = "";
        };
        inherit shellAliases;
        systemPackages = with pkgs; [
          fzf
          jq
          zsh
        ];
      };
      programs.ssh.extraConfig = ''
        AddKeysToAgent yes
        IdentityFile ~/.ssh/keys/git
        IdentityFile ~/.ssh/keys/git-sign
      '';
      programs.zsh = {
        enable = true;
        histFile = "$HOME/.config/zsh/history";
        histSize = 10000;
        enableCompletion = true;
        interactiveShellInit = lib.mkMerge [
          (lib.mkBefore ''
            if [[ -n "$GHOSTTY_RESOURCES_DIR" ]]; then
              builtin source "$GHOSTTY_RESOURCES_DIR"/shell-integration/zsh/ghostty-integration
            fi
          '')
          (lib.mkAfter ''
            ${strShellAliases}
            mkdir -p "$HOME/.local/state/less"
            if [ -n "$SSH_AUTH_SOCK" ]; then
              ssh-add ~/.ssh/keys/{git,git-sign} 2>/dev/null
            fi
            jsonfmt() {
              if [ -z "$1" ]; then
                echo "Usage: formatjson <filename.json>"
                return 1
              fi
              ${pkgs.jq}/bin/jq . "$1" > "$1.tmp" && mv "$1.tmp" "$1"
            }
            function y() {
              local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
              command yazi "$@" --cwd-file="$tmp"
              if cwd="$(<"$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
                builtin cd -- "$cwd"
              fi
              rm -f -- "$tmp"
            }
            ns() {
              local args=() prev=""
              for a in "$@"; do
                case "$a" in
                  -*|*#*|*:*|/*|.*) args+=("$a") ;;
                  *)
                    if [ "$prev" = "--command" ] || [ "$prev" = "-c" ]; then
                      args+=("$a")
                    else
                      args+=("nixpkgs#$a")
                    fi
                    ;;
                esac
                prev="$a"
              done
              nix shell "''${args[@]}"
            }
            nr() {
              if [ "$#" -eq 0 ]; then
                echo "Usage: nr <package> [-- args]" >&2
                return 1
              fi
              local pkg="$1"; shift
              nix run "nixpkgs#$pkg" "$@"
            }
            bindkey ' ' magic-space
            zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
            export FZF_DEFAULT_OPTS="${fzfTheme}"
            export FZF_CTRL_R_COMMAND=""
            if [[ -f "${pkgs.fzf}/share/fzf/key-bindings.zsh" ]]; then
              builtin source "${pkgs.fzf}/share/fzf/key-bindings.zsh"
            fi
            md() {
              if [ "$#" -eq 0 ]; then
                echo "Usage: md <dir>..." >&2
                return 1
              fi
              mkdir -p "$@" || return
              local dir
              for dir in "$@"; do :; done
              builtin cd -- "$dir"
            }
          '')
        ];
      };
    };
    nixos = {
      default = self.modules.nixos.zsh;
      zsh = {lib, ...}: {
        imports = [self.modules.generic.zsh];
        programs.ssh.startAgent = lib.mkDefault true;
        programs.zsh = {
          autosuggestions.enable = true;
          syntaxHighlighting.enable = true;
        };
      };
    };
    darwin = {
      default = self.modules.darwin.zsh;
      zsh = _: {
        imports = [self.modules.generic.zsh];
        programs.zsh = {
          enableAutosuggestions = true;
          enableSyntaxHighlighting = true;
        };
      };
    };
  };
}
