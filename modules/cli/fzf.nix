{
  flake.modules.homeManager.cli = _: {
    programs.fzf = {
      enable = true;
      defaultOptions = ["--preview 'bat --style=numbers --color=always {}'"];
    };
  };
}
