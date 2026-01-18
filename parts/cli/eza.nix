{
  flake.modules.homeManager.cli = _: {
    programs.eza = {
      enable = true;
      icons = "auto";
      extraOptions = [
        "-lh"
        "--group-directories-first"
      ];
    };
  };
}
