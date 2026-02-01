{
  flake.modules = {
    nixos.vscode = _: {
      programs.vscode.enable = true;
    };
    homeManager.vscode = _: {
      programs.vscode.enable = true;
    };
  };
}
