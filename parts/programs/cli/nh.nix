{
  flake.modules.nixos.cli = {
    programs.nh = {
      enable = true;
      flake = "$HOME/dendrix";
      clean.enable = true;
    };
  };
  flake.modules.homeManager.cli = {
    programs.nh = {
      enable = true;
      flake = "$HOME/dendrix";
      clean.enable = true;
    };
  };
}
