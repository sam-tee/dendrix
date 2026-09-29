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
      environment.systemPackages = with pkgs; [gh git];
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
        xdg.config.files."git/config".text = lib.generators.toGitINI {
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
}
