let
  mkTemplate = name: description: {
    inherit description;
    path = ./../templates/${name};
  };
in {
  flake.templates = {
    darwin = mkTemplate "darwin" "Darwin system flake";
    go = mkTemplate "go" "Dev tools for golang";
    go-package = mkTemplate "go-package" "Flake to build golang package with necessary dev tools";
    home = mkTemplate "home" "Home-manager config flake";
    jovian = mkTemplate "jovian" "Nixos system with jovian setup";
    latex = mkTemplate "latex" "Flake to write LaTeX doc locally";
    nixos = mkTemplate "nixos" "Simple nixos config flake";
    minimal = mkTemplate "minimal" "Minimal flake";
    mobile = mkTemplate "mobile" "Mobile nixos config";
    python = mkTemplate "python" "Dev tools for python";
    shell = mkTemplate "shell" "Empty devShell flake";
  };
}
