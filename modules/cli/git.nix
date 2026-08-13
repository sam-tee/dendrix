{self, ...}: {
  flake.modules.generic = {
    default = self.modules.generic.git;
    git = {
      lib,
      pkgs,
      ...
    }: {
      environment.systemPackages = with pkgs; [gh git];
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
