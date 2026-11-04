{
  lib,
  self,
  ...
}: let
  inherit (lib) escapeShellArg filterAttrs mapAttrsToList mkAfter mkBefore mkDefault mkMerge;
in {
  flake.modules = {
    generic.zsh = {
      config,
      pkgs,
      ...
    }: let
      inherit (config.xdg.dirs) cacheDir configDir dataDir stateDir;
      zdotDir = "${configDir}/zsh";
      shellAliases = {
        "l" = "eza --icons auto -l --group-directories-first";
        "ls" = "l -a";
        "lt" = "l -aT --level=2";
        "ltt" = "l -T";
        "lg" = "lazygit";
        "py" = "python3";
        "cat" = "bat --paging=never --style=plain";
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
      };
      strShellAliases =
        shellAliases
        |> filterAttrs (_: v: v != null)
        |> mapAttrsToList (k: v: "alias -- ${k}=${escapeShellArg v}")
        |> builtins.concatStringsSep "\n";
      fzfTheme = "--color=base16";
    in {
      environment = {
        variables = {
          XDG_CACHE_HOME = cacheDir;
          XDG_CONFIG_HOME = configDir;
          XDG_DATA_HOME = dataDir;
          XDG_STATE_HOME = stateDir;
          ZDOTDIR = zdotDir;
          EDITOR = "nvim";
          VISUAL = "nvim";
          PAGER = "less";
          LESS = "-FRX --quit-if-one-screen";
          LESSHISTFILE = "${stateDir}/less/history";
          TERMINFO_DIRS = ["${dataDir}/terminfo"];
          NPM_CONFIG_USERCONFIG = "${configDir}/npm/npmrc";
          NPM_CONFIG_CACHE = "${cacheDir}/npm";
          NPM_CONFIG_PREFIX = "${dataDir}/npm";
          NODE_REPL_HISTORY = "${stateDir}/node_repl_history";
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
        histFile = "${zdotDir}/history";
        histSize = 10000;
        enableCompletion = true;
        # replaced by the cached compinit at the end of interactiveShellInit
        enableGlobalCompInit = false;
        # ZDOTDIR has no rc files, so nixpkgs' zsh (the `zsh` on PATH) would
        # otherwise launch the new-user wizard on every start
        shellInit = ''
          zsh-newuser-install() { :; }
        '';
        interactiveShellInit = mkMerge [
          (mkBefore ''
            if [[ -n "$GHOSTTY_RESOURCES_DIR" ]]; then
              builtin source "$GHOSTTY_RESOURCES_DIR"/shell-integration/zsh/ghostty-integration
            fi
          '')
          (mkAfter ''
            ${strShellAliases}
            [[ -d "${stateDir}/less" ]] || mkdir -p "${stateDir}/less"
            # atuin hardcodes ~/.atuin/logs and ignores XDG; redirect it into state
            [[ -d "${stateDir}/atuin/logs" ]] || mkdir -p "${stateDir}/atuin/logs"
            if [ ! -L "$HOME/.atuin" ]; then
              if [ -d "$HOME/.atuin/logs" ]; then
                mv "$HOME/.atuin/logs"/* "${stateDir}/atuin/logs/" 2>/dev/null || true
              fi
              rm -rf "$HOME/.atuin"
              ln -s "${stateDir}/atuin" "$HOME/.atuin"
            fi
            if [ -n "$SSH_AUTH_SOCK" ]; then
              ssh-add ~/.ssh/keys/{git,git-sign} >/dev/null 2>&1 &!
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
            autoload -U compinit
            () {
              local dump="''${ZDOTDIR:-$HOME}/.zcompdump"
              local sys=/run/current-system
              sys=''${sys:A}
              if [[ -s $dump && -r $dump.sys && "$(<$dump.sys)" == "$sys" ]]; then
                compinit -C -d "$dump"
              else
                compinit -d "$dump" && print -r -- "$sys" >| "$dump.sys"
              fi
            }
          '')
        ];
      };
    };
    nixos = {
      default = self.modules.nixos.zsh;
      zsh = _: {
        imports = [self.modules.generic.zsh];
        programs.ssh.startAgent = mkDefault true;
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
