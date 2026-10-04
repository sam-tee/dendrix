{self, ...}: {
  flake.modules.generic = {
    default = self.modules.generic.git;
    git = {
      config,
      username,
      lib,
      pkgs,
      ...
    }: {
      environment.systemPackages = with pkgs; [delta gh git];
      sops.secrets."gh-token".owner = username;
      sops.templates."gh-hosts.yml" = {
        owner = username;
        mode = "0600";
        path = "${config.users.users.${username}.home}/.config/gh/hosts.yml";
        content = ''
          github.com:
            user: sam-tee
            oauth_token: ${config.sops.placeholder."gh-token"}
            git_protocol: ssh
        '';
      };
      hjem.extraModules = lib.singleton {
        xdg.config.files = {
          "git/config".text = lib.generators.toGitINI {
            commit.gpgSign = true;
            core.pager = "delta";
            url."ssh://forgejo@${self.services.forgejo.fqdn}/".insteadOf = "https://${self.services.forgejo.fqdn}/";
            delta = {
              navigate = true;
              line-numbers = true;
            };
            diff.colorMoved = "default";
            gpg.format = "ssh";
            init.defaultBranch = "main";
            interactive.diffFilter = "delta --color-only";
            merge.conflictStyle = "diff3";
            pull.rebase = true;
            push.autoSetupRemote = true;
            user = {
              name = "Sam Tee";
              email = "sam.tee4@proton.me";
              signingKey = self.hosts.git-sign.pubKey;
            };
          };
          "git/ignore".text = ''
            .direnv/
            .devenv/
            result
            result-*
            .venv/
            __pycache__/
            *.py[cod]
            node_modules/
            .DS_Store
          '';
        };
      };
    };
  };
}
