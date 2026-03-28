let
  cli = _: {
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };
  };
in {
  flake.modules = {
    nixos = {inherit cli;};
    homeManager = {inherit cli;};
  };
}
