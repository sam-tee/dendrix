let
  starship = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile ./starship.toml);
  };
in {
  flake.modules = {
    nixos.cli.programs = {inherit starship;};
    homeManager.cli.programs = {inherit starship;};
  };
}
