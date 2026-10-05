{self, ...}: {
  flake.modules.generic = {
    default = self.modules.generic.git;
    git = {
      config,
      username,
      lib,
      pkgs,
      ...
    }: let
      inherit (config.users.users.${username}) home;
    in {
      environment.systemPackages = with pkgs; [delta gh git];
      sops.secrets."gh-token".owner = username;
      sops.templates."gh-hosts.yml" = {
        owner = username;
        mode = "0600";
        path = "${home}/.config/gh/hosts.yml";
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
            gpg.ssh.allowedSignersFile = "${home}/.config/git/allowed_signers";
            init.defaultBranch = "main";
            interactive.diffFilter = "delta --color-only";
            merge.conflictStyle = "diff3";
            pull.rebase = true;
            push.autoSetupRemote = true;
            user = {
              name = "Sam Tee";
              email = "sam.tee4@proton.me";
              signingKey = "${home}/.ssh/keys/git-sign.pub";
            };
          };
          "git/allowed_signers".text = "sam.tee4@proton.me ${self.hosts.git-sign.pubKey}\n";
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
