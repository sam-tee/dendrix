{
  flake.modules.nixos.cli = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      gh
      git
    ];
    programs.git.enable = true;
  };
  flake.modules.home.cli = {
    programs.gh.enable = true;
    programs.git = {
      enable = true;
      settings = {
        init.defaultBranch = "main";
        pull.rebase = "true";
        push.autoSetupRemote = "true";
        user = {
          name = "sam-tee";
          email = "93236986+akhlus@users.noreply.github.com";
        };
      };};
  };
  flake.modules.darwin.cli = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      gh
      git
    ];
  };
}
