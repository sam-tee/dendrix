let
alias = {
  "la" = "ls -a";
  "lt" = "eza --tree --level=2 --long --git";
  "lta" = "lt -a";
  "py" = "python3";
};
  programs = {
  zsh = {
    enable = true;
    shellAliases = alias;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };
  bash = {
    enable = true;
    shellAliases = alias;
  };
  };
in{
  flake.modules.nixos.cli = {
    inherit programs;
  };
  flake.modules.darwin.cli = {
    programs = {
      zsh = {
        enable = true;
        enableAutosuggestions = true;
        enableSyntaxHighlighting = true;
      };
      bash = {
        enable = true;
        completion.enable = true;
      };
    };
  };
  flake.modules.home.cli = {
    inherit programs;
  };
}
