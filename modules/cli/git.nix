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
      ghTokenSops = config.sops.placeholder."gh-token";
    in {
      environment.systemPackages = with pkgs; [gh git];
      sops.secrets."gh-token".owner = username;
      hjem.extraModules = lib.singleton {
        xdg.config.files = {
          "gh/hosts.yml".text = ''
            github.com:
              user: sam-tee
              oauth_token: ${ghTokenSops}
              git_protocol: ssh
          '';
          "git/config".text = lib.generators.toGitINI {
            commit.gpgSign = true;
            gpg.format = "ssh";
            init.defaultBranch = "main";
            pull.rebase = true;
            push.autoSetupRemote = true;
            user = {
              name = "Sam Tee";
              email = "sam.tee4@proton.me";
              signingKey = self.hosts.git-sign.pubKey;
            };
          };
        };
      };
    };
  };
}
