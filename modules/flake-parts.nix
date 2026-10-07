{
  inputs,
  self,
  ...
}: {
  imports = [inputs.flake-parts.flakeModules.modules];
  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "aarch64-darwin"
  ];
  perSystem = {pkgs, ...}: {
    formatter = pkgs.alejandra;
    checks = {
      alejandra =
        pkgs.runCommand "alejandra-check" {
          src = self;
          nativeBuildInputs = [pkgs.alejandra];
        } ''
          alejandra --check "$src"
          touch $out
        '';
      statix =
        pkgs.runCommand "statix-check" {
          src = self;
          nativeBuildInputs = [pkgs.statix];
        } ''
          statix check "$src"
          touch $out
        '';
      deadnix =
        pkgs.runCommand "deadnix-check" {
          src = self;
          nativeBuildInputs = [pkgs.deadnix];
        } ''
          deadnix --fail "$src"
          touch $out
        '';
    };
  };
}
