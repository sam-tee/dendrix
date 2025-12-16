{
  flake.modules.nixos.vscode = {
    programs.vscode.enable = true;
  };
  flake.modules.home.vscode = {
    programs.vscode.enable = true;
  };
}
