{self, ...}: {
  flake.modules = {
    nixos.cli = _: {
      programs.git.enable = true;
    };
    homeManager.cli = _: {
      programs.gh.enable = true;
      programs.git = {
        enable = true;
        signing = {
          format = "ssh";
          key = self.hosts.git-sign.pubKey;
          signByDefault = true;
        };
        settings = {
          gpg.format = "ssh";
          init.defaultBranch = "main";
          pull.rebase = "true";
          push.autoSetupRemote = "true";
          user = {
            name = "Sam Tee";
            email = "sam.tee4@proton.me";
          };
        };
      };
    };
    darwin.cli = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        git
      ];
    };
  };
}
