{
  flake.modules.homeManager.cli = {
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
