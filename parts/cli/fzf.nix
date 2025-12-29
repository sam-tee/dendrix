{
  flake.modules.homeManager.cli = {
    programs.fzf = {
      enable = true;
      defaultOptions = ["--preview 'bat --style=numbers --color=always {}'"];
    };
  };
}
