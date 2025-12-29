{
  flake.modules.nixos.vscode = {
    programs.vscode.enable = true;
  };
  flake.modules.homeManager.vscode = {
    programs.vscode.enable = true;
  };
}
