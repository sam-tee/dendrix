{
  flake.modules.homeManager.cli = _: {
    programs.eza = {
      enable = true;
      icons = "auto";
      extraOptions = [
        "-la"
        "--group-directories-first"
      ];
    };
  };
}
