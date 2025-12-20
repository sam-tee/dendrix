let
nh = {
  enable = true;
  flake = "$HOME/dendrix";
  clean.enable = true;
};
in{
  flake.modules.nixos.cli.programs = {inherit nh;};
  flake.modules.homeManager.cli.programs = {inherit nh;};
}
