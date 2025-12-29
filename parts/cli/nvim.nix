let
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };
in {
  flake.modules.nixos.cli = {
    inherit programs;
  };
  flake.modules.homeManager.cli = {
    inherit programs;
  };
}
