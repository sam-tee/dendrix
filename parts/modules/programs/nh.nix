{...}: let
  programs.nh = {
    enable = true;
    flake = "$HOME/dendrix";
    clean.enable = true;
  };
in {
  flake.modules.nixos.cli = {inherit programs;};
  flake.modules.home.cli = {inherit programs;};
}
