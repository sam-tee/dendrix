{self, ...}: {
  flake.modules = {
    generic.zsh = {
      lib,
      pkgs,
      ...
    }: {
      environment = {
        variables.ZDOTDIR = "$HOME/.config/zsh";
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
        interactiveShellInit = lib.mkAfter ''
          jsonfmt() {
            if [ -z "$1" ]; then
              echo "Usage: formatjson <filename.json>"
              return 1
            fi

            ${pkgs.jq}/bin/jq . "$1" > "$1.tmp" && mv "$1.tmp" "$1"
          }

          bindkey ' ' magic-space
          zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
        '';
      };
    };
    nixos = {
      default = self.modules.nixos.zsh;
      zsh = _: {
        imports = [self.modules.generic.zsh];
        programs.ssh.startAgent = true;
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
