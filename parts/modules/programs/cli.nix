let
programs = {
bat.enable = true;
direnv = {
  enable = true;
  nix-direnv.enable = true;
};
eza = {
  enable = true;
  icons = "auto";
  extraOptions = [
    "-lh"
    "--group-directories-first"
  ];
};
fzf = {
  enable = true;
  defaultOptions = ["--preview 'bat --style=numbers --color=always {}'"];
};
lazygit.enable = true;
ripgrep.enable = true;
starship = {
  enable = true;
  settings = builtins.fromTOML (builtins.readFile ./starship.toml);
};
tmux.enable = true;
zoxide.enable = true;
};
in{
  flake.modules.nixos.cli = {
    inherit programs;
  };
  flake.modules.home.cli = {
    inherit programs;
  };
  flake.modules.darwin.cli = {pkgs, ...}:{
    environment.systemPackages = with pkgs; [
      bat
      direnv
      eza
      fzf
      lazygit
      starship
      tmux
      zoxide
    ];
  };
}
