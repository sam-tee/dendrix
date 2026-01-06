let
  mkTemplate = name: description: {
    inherit description;
    path = ./_templates/${name};
  };
in {
  flake.templates = {
    fp = mkTemplate "fp" "Flake-parts flake template";
    go = mkTemplate "go" "Dev tools for golang";
    go-package = mkTemplate "go-package" "Flake to build golang package with necessary dev tools";
    latex = mkTemplate "latex" "Flake to write LaTeX doc locally";
    minimal = mkTemplate "minimal" "Minimal flake";
    mobile = mkTemplate "mobile" "Mobile nixos config";
    python = mkTemplate "python" "Dev tools for python";
    shell = mkTemplate "shell" "Empty devShell flake";
  };
}
