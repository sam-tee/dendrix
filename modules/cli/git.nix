{
  flake.modules = {
    nixos.cli = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        gh
        git
      ];
      programs.git.enable = true;
    };
    homeManager.cli = _: {
      programs.gh.enable = true;
      programs.git = {
        enable = true;
        settings = {
          init.defaultBranch = "main";
          pull.rebase = "true";
          push.autoSetupRemote = "true";
          user = {
            name = "sam-tee";
            email = "93236986+sam-tee@users.noreply.github.com";
          };
        };
      };
    };
    darwin.cli = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        gh
        git
      ];
    };
  };
}
