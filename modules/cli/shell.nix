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
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        "md" = "mkdir -p";
      };
      strShellAliases =
        shellAliases
        |> lib.filterAttrs (k: v: v != null)
        |> lib.mapAttrsToList (k: v: "alias -- ${k}=${lib.escapeShellArg v}")
        |> builtins.concatStringsSep "\n";
    in {
      environment = {
        variables = {
          XDG_CACHE_HOME = "$HOME/.cache";
          XDG_CONFIG_HOME = "$HOME/.config";
          XDG_DATA_HOME = "$HOME/.local/share";
          XDG_STATE_HOME = "$HOME/.local/state";
          ZDOTDIR = "$HOME/.config/zsh";
        };
        inherit shellAliases;
        systemPackages = with pkgs; [
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
            bindkey ' ' magic-space
            zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
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
